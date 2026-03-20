from constants import C
from tui.formatters import (
    adf_to_ansi,
    get_priority_icon,
    get_status_style,
    format_date,
    format_datetime,
)


def build_issue_registry(raw_issues, terminal_width):
    """Organizes flat API issues into a dictionary with ANSI-formatted strings."""
    wrap_width = min(90, terminal_width - 6)

    divider = f"{C['dim']}{'─' * 64}{C['reset']}"

    registry = {}

    for issue in raw_issues:
        key, f = issue["key"], issue.get("fields", {})
        itype = f.get("issuetype", {})
        assignee = f.get("assignee")
        clist = f.get("comment", {}).get("comments", [])

        comments_ansi = ""
        if clist:
            comments_ansi = f"\n\n{divider}\n\n{C['yellow']}{C['bold']}󱠁 LATEST COMMENTS{C['reset']}\n\n"
            for c in clist[-3:]:
                auth = c.get("author", {}).get("displayName", "Unknown")
                created_dt = format_datetime(c.get("created"))
                body = adf_to_ansi(c.get("body"), wrap_width).strip()
                comments_ansi += f"{C['bold']}{auth}{C['reset']}  {C['dim']}• {created_dt}{C['reset']}\n{body}\n\n"

        desc = adf_to_ansi(f.get("description"), wrap_width).strip()
        if not desc:
            desc = f"{C['dim']}{C['italic']}No description provided.{C['reset']}"

        reporter = (
            f.get("reporter", {}).get("displayName", "Unassigned")
            if f.get("reporter")
            else "Unassigned"
        )
        created = format_date(f.get("created"))
        updated = format_date(f.get("updated"))
        labels = ", ".join(f.get("labels", []))
        components = ", ".join([c.get("name") for c in f.get("components", [])])

        registry[key] = {
            "key": key,
            "summary": f.get("summary"),
            "description": desc,
            "comments": comments_ansi,
            "type": itype.get("name", "Unknown"),
            "type_id": itype.get("id"),
            "status": f.get("status", {}).get("name"),
            "priority": f.get("priority", {}).get("name"),
            "user": assignee.get("displayName") if assignee else "Unassigned",
            "reporter": reporter,
            "created": created,
            "updated": updated,
            "labels": labels,
            "components": components,
            "parent_key": (f.get("parent") or {}).get("key"),
            "children": {},
        }
    return registry


def build_fzf_preview(registry, type_order_map, terminal_width, team_name="TEAM"):
    """
    Pure: Flattens the registry into FZF lines and rich preview blocks.
    """
    lines, previews = [], {}
    known_children = {k for k, v in registry.items() if v["parent_key"]}
    SUMM_W = terminal_width - 65

    divider = f"{C['dim']}{'─' * 64}{C['reset']}"

    for key, issue in registry.items():
        pk = issue["parent_key"]
        if pk and pk in registry:
            registry[pk]["children"][key] = issue

    def flatten(nodes, depth=0):
        sorted_nodes = sorted(
            nodes,
            key=lambda x: (
                type_order_map.get(str(x.get("type_id")), (100, "", False))[0],
                x["key"],
            ),
        )

        for n in sorted_nodes:
            st_color, st_icon = get_status_style(n["status"])
            type_color = type_order_map.get(
                str(n.get("type_id")), (100, C["reset"], False)
            )[1]

            bc = f" {C['dim']}❯{C['reset']} "
            ident_line = (
                f"{C['magenta']} {team_name.upper()}{C['reset']}{bc}"
                f"{C['bold']}{n['key']}{C['reset']}{bc}"
                f"{type_color} {n['type'].upper()}{C['reset']}{bc}"
                f"{st_color}{st_icon} {n['status'].upper()}{C['reset']}{bc}"
                f"{get_priority_icon(n['priority'])} {n['priority'].upper()}"
            )

            def pad(text, width=22):
                return (
                    text[: width - 3] + "..."
                    if len(text) > width
                    else text.ljust(width)
                )

            u_val = pad(n["user"])
            r_val = pad(n["reporter"])

            row1 = f"{C['cyan']} Assignee:   {C['reset']}{u_val} {C['dim']} Created: {C['reset']}{n['created']}"
            row2 = f"{C['dim']} Reporter:   {C['reset']}{r_val} {C['dim']} Updated: {C['reset']}{n['updated']}"

            header_lines = [ident_line, row1, row2]

            if n["components"]:
                header_lines.append(
                    f"{C['blue']} Components: {C['reset']}{n['components']}"
                )
            if n["labels"]:
                header_lines.append(
                    f"{C['magenta']} Labels:     {C['reset']}{n['labels']}"
                )

            header_block = "\n".join(header_lines)

            header_block += (
                f"\n{divider}\n{C['bold']}{n['summary'].upper()}{C['reset']}\n\n"
            )

            children_ansi = ""
            if n["children"]:
                children_ansi = f"\n\n{divider}\n\n{C['blue']}{C['bold']}󰙔 CHILD ISSUES{C['reset']}\n\n"
                sorted_children = sorted(
                    n["children"].values(),
                    key=lambda x: (
                        type_order_map.get(str(x.get("type_id")), (100, "", False))[0],
                        x["key"],
                    ),
                )
                for c in sorted_children:
                    c_st_color, c_st_icon = get_status_style(c["status"])
                    c_type_color = type_order_map.get(
                        str(c.get("type_id")), (100, C["reset"], False)
                    )[1]
                    children_ansi += (
                        f"  {C['dim']}↳{C['reset']} "
                        f"{c_type_color}{c['key']:<11}{C['reset']} "
                        f"{c_st_color}{c_st_icon} {c['status'][:14]:<14}{C['reset']} "
                        f"{c['summary']}\n"
                    )

            previews[n["key"]] = (
                f"{header_block}{n['description']}{children_ansi}{n['comments']}"
            )

            indent = "  " * depth
            pref = "└─ " if depth > 0 else " "

            raw_summary = f"{indent}{pref}{n['summary']}"
            if len(raw_summary) > SUMM_W:
                display_summary = raw_summary[: SUMM_W - 3] + "..."
            else:
                display_summary = raw_summary

            if n["type"].lower() == "task":
                summary_color = C["default"]
            else:
                summary_color = type_color

            display_summary = f"{summary_color}{display_summary}{C['reset']}"

            child_count = len(n["children"])
            if child_count > 0:
                display_summary = f"{C['bold']}{display_summary} {C['dim']}({child_count} sub){C['reset']}"

            lines.append(
                f"{type_color}{n['key']:<12}{C['reset']} "
                f"{get_priority_icon(n['priority'])} "
                f"{type_color}{n['type'][:10]:<10}{C['reset']} "
                f"{st_color}{n['status'][:16]:<16}{C['reset']} "
                f"{C['dim']}{n['user'][:16]:<16}{C['reset']} "
                f"{display_summary}"
            )

            flatten(n["children"].values(), depth + 1)

    roots = [v for k, v in registry.items() if k not in known_children]
    flatten(roots)
    return lines, previews
