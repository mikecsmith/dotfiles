import sys
import json
import subprocess
import re
from constants import C
from tui.terminal import prompt_numeric_menu


def execute_bootstrap(project_key, client, cfg):
    """Scaffolds a complete config.yaml block by auto-discovering Jira metadata."""
    project_key = project_key.upper()
    
    # Send all progress logs to STDERR so they don't corrupt piped output
    print(f"{C['dim']}Searching for boards linked to project {project_key}...{C['reset']}", file=sys.stderr)

    boards = client.fetch_boards_for_project(project_key)
    if not boards:
        print(f"{C['red']}No boards found for project {project_key}.{C['reset']}", file=sys.stderr)
        sys.exit(1)

    # Sort the boards alphabetically by name for a cleaner menu
    boards = sorted(boards, key=lambda b: b.get("name", "").lower())

    options = [f"{b['name']} {C['dim']}(ID: {b['id']}){C['reset']}" for b in boards]
    
    choice_idx = prompt_numeric_menu(
        options, 
        f"󰡃 SELECT BOARD FOR {project_key}", 
        color=C["cyan"]
    )

    if choice_idx is None:
        print(f"{C['dim']}Bootstrap cancelled.{C['reset']}", file=sys.stderr)
        sys.exit(0)

    selected_board = boards[choice_idx]
    board_id = selected_board["id"]
    board_name = selected_board["name"]

    print(f"{C['dim']}Fetching configuration for board {board_name} ({board_id})...{C['reset']}", file=sys.stderr)
    try:
        board_cfg = client.fetch_board_config(board_id)
    except Exception as e:
        print(f"{C['red']}Failed to fetch board {board_id}: {e}{C['reset']}", file=sys.stderr)
        sys.exit(1)

    filter_id = board_cfg.get("filter", {}).get("id")
    board_slug = board_name.lower().replace(" ", "_")

    print(f"{C['dim']}Fetching base JQL for filter ID {filter_id}...{C['reset']}", file=sys.stderr)
    filter_data = client.fetch_filter(filter_id)
    base_jql = filter_data.get("jql", "")

    print(f"{C['dim']}Fetching status definitions for readable JQL...{C['reset']}", file=sys.stderr)
    all_statuses = client.fetch_statuses()
    status_map = {str(s.get("id")): s for s in all_statuses}

    columns = board_cfg.get("columnConfig", {}).get("columns", [])
    column_names = []
    visible_statuses = []
    done_statuses = []

    for col in columns:
        column_names.append(col.get("name"))
        for status in col.get("statuses", []):
            status_id = str(status.get("id"))
            if status_id in status_map:
                s_obj = status_map[status_id]
                s_name = s_obj.get("name")
                
                visible_statuses.append(s_name)
                
                # Check if this status is Green (Done category)
                cat_key = s_obj.get("statusCategory", {}).get("key")
                if cat_key == "done":
                    done_statuses.append(s_name)

    status_jql_list = ", ".join(f'"{s}"' for s in visible_statuses)
    done_jql_list = ", ".join(f'"{s}"' for s in done_statuses) if done_statuses else '"Done"'

    print(f"{C['dim']}Hunting for required Custom Fields...{C['reset']}", file=sys.stderr)
    all_fields = client.fetch_fields()
    cf_map = {}
    team_candidates = []

    for f in all_fields:
        fname = f.get("name", "").lower()
        fid_raw = f.get("id", "")
        if fid_raw.startswith("customfield_"):
            fid = int(fid_raw.replace("customfield_", ""))
            if fname == "team":
                team_candidates.append(fid)
            elif fname == "epic name":
                cf_map["epic_name"] = fid
            elif fname == "epic link":
                cf_map["epic_link"] = fid

    if 15000 in team_candidates:
        cf_map["team"] = 15000
    elif team_candidates:
        cf_map["team"] = team_candidates[0]
    else:
        cf_map["team"] = "TODO_FIND_TEAM_ID"

    if "epic_name" not in cf_map: cf_map["epic_name"] = "TODO_FIND_EPIC_NAME_ID"
    if "epic_link" not in cf_map: cf_map["epic_link"] = "TODO_FIND_EPIC_LINK_ID"

    print(f"{C['dim']}Interpolating variables into JQL...{C['reset']}", file=sys.stderr)
    team_id = cf_map.get("team")
    team_uuid = None

    if team_id and team_id != "TODO_FIND_TEAM_ID":
        team_regex = rf"(?:cf\[{team_id}\]|customfield_{team_id})\s*(?:=|in)\s*\(?\s*([a-zA-Z0-9\-]+)\s*\)?"
        team_match = re.search(team_regex, base_jql, re.IGNORECASE)
        if team_match:
            team_uuid = team_match.group(1)
            base_jql = re.sub(team_regex, '{team} = "{team_uuid}"', base_jql, flags=re.IGNORECASE)

    project_regex = r"project\s*(?:=|in)\s*\(?\s*\d+\s*\)?"
    base_jql = re.sub(project_regex, 'project = "{project_key}"', base_jql, flags=re.IGNORECASE)

    print(f"{C['dim']}Mapping Issue Types specifically for Project {project_key}...{C['reset']}", file=sys.stderr)
    project_data = client.fetch_project(project_key)
    project_types = project_data.get("issueTypes", [])

    types_list = []
    seen_names = set()

    target_types = {
        "initiative": {"order": 10, "color": "cyan"},
        "epic": {"order": 20, "color": "magenta"},
        "story": {"order": 30, "color": "blue"},
        "task": {"order": 30, "color": "default"},
        "bug": {"order": 30, "color": "red"},
        "sub-task": {"order": 40, "color": "white"},
    }

    for t in project_types:
        tname = t.get("name", "")
        tname_lower = tname.lower()

        if tname_lower not in seen_names:
            match = target_types.get(tname_lower, {"order": 99, "color": "default"})
            types_list.append(
                {
                    "id": int(t.get("id")),
                    "name": tname,
                    "order": match["order"],
                    "color": match["color"],
                    "has_children": not t.get("subtask", False),
                }
            )
            seen_names.add(tname_lower)

    types_list = sorted(types_list, key=lambda k: k["order"])

    board_payload = {
        "id": board_id,
        "name": board_name,
        "project_key": project_key,
    }
    
    if team_uuid:
        board_payload["team_uuid"] = team_uuid

    board_payload.update({
        "jql": base_jql,
        "filters": { 
            "all": "",
            "active": f"status IN ({status_jql_list}) AND (statusCategory != Done OR (statusCategory = Done AND status CHANGED TO ({done_jql_list}) AFTER -2w))",
            "me": "assignee = currentUser() AND statusCategory != Done",
        },
        "transitions": column_names,
        "types": types_list,
    })
    
    scaffold_dict = {}

    if cfg.get("_prompted_for_server"):
        scaffold_dict["server"] = cfg["server"]
        scaffold_dict["default_board"] = board_slug
        scaffold_dict["default_filter"] = "active"  # <-- CHANGED
        scaffold_dict["editor"] = "vim"

    scaffold_dict["custom_fields"] = cf_map
    scaffold_dict["boards"] = {
        board_slug: board_payload
    }

    json_payload = json.dumps(scaffold_dict)

    try:
        p = subprocess.run(
            ["yq", "eval", "-P", "-"],
            input=json_payload,
            text=True,
            capture_output=True,
            check=True,
        )
        yaml_output = p.stdout
    except subprocess.CalledProcessError as e:
        print(f"{C['red']}yq parsing error: {e.stderr}{C['reset']}", file=sys.stderr)
        sys.exit(1)

    if sys.stdout.isatty():
        print(f"\n{C['green']}{C['bold']}✅ Configuration Scaffolded!{C['reset']}")
        print(f"Merge this block into your {C['cyan']}~/.config/ihj/config.yaml{C['reset']}:\n")
        print(f"{C['dim']}# {'─' * 50}{C['reset']}")
        print(yaml_output.rstrip())
        print(f"{C['dim']}# {'─' * 50}{C['reset']}\n")
    else:
        print(yaml_output.rstrip())
