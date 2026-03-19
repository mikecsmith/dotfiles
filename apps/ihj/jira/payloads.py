def build_search_payload(jql, custom_field_map, next_token=None):
    """Builds the dict payload needed for the Jira search API."""
    fields_to_fetch = [
        "summary",
        "issuetype",
        "status",
        "priority",
        "parent",
        "subtasks",
        "description",
        "assignee",
        "comment",
        "reporter",
        "created",
        "updated",
        "labels",
        "components",
    ]

    if "epic_name_id" in custom_field_map:
        fields_to_fetch.append(custom_field_map["epic_name_id"])
    if "epic_link_id" in custom_field_map:
        fields_to_fetch.append(custom_field_map["epic_link_id"])

    payload = {"jql": jql, "fields": fields_to_fetch, "maxResults": 100}
    if next_token:
        payload["nextPageToken"] = next_token

    return payload


def parse_search_response(response_body):
    """Extracts issues and pagination state."""
    issues = response_body.get("issues", [])
    next_token = response_body.get("nextPageToken")
    is_last = response_body.get("isLast", True)

    if not next_token:
        is_last = True

    return issues, next_token, is_last


def build_transition_payload(transition_id):
    """Constructs body for status change."""
    return {"transition": {"id": transition_id}}


def build_assignment_payload(account_id):
    """Constructs body for assignee change."""
    return {"accountId": account_id}


def filter_transitions(api_transitions, allowed_names):
    """Filters API results against the user's YAML preference."""
    if not allowed_names:
        return api_transitions
    filtered = []
    for target in allowed_names:
        for t in api_transitions:
            if t.get("name", "").lower() == target.lower():
                filtered.append(t)
                break
    return filtered


def build_upsert_payload(
    frontmatter_dict,
    adf_description,
    config_types,
    custom_fields_map,
    project_key=None,
    team_uuid=None,
):
    """Constructs the POST/PUT payload from the parsed frontmatter."""
    fields = {
        "summary": frontmatter_dict.get("summary", "Untitled"),
        "description": adf_description,
    }

    issue_type = frontmatter_dict.get("type")
    if issue_type:
        type_id = next((t["id"] for t in config_types if t["name"] == issue_type), None)
        if type_id:
            fields["issuetype"] = {"id": str(type_id)}

    priority = frontmatter_dict.get("priority")
    if priority:
        fields["priority"] = {"name": priority}

    parent = frontmatter_dict.get("parent")
    if parent:
        fields["parent"] = {"key": parent.upper()}

    # Dynamically inject custom fields
    for cf_name, cf_id in custom_fields_map.items():
        val = frontmatter_dict.get(cf_name)
        if val is not None and val != "":
            if cf_name == "team" and val is True and team_uuid:
                fields[f"customfield_{cf_id}"] = str(team_uuid)
            elif cf_name != "team":
                fields[f"customfield_{cf_id}"] = str(val)

    if project_key:
        fields["project"] = {"key": project_key}

    return {"fields": fields}


def build_comment_payload(adf_body):
    """Constructs the POST payload for adding a comment."""
    return {"body": adf_body}
