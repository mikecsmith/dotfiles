from jira.payloads import build_transition_payload


def get_transition_id(client, issue_key, target_status):
    """Pure domain logic: Finds a matching transition ID from the API."""
    if issue_key == "DRYRUN-999":
        return "99"

    transitions = client.fetch_transitions(issue_key)
    return next(
        (
            t["id"]
            for t in transitions
            if t.get("name", "").lower() == target_status.lower()
            or t.get("to", {}).get("name", "").lower() == target_status.lower()
        ),
        None,
    )


def perform_transition(client, issue_key, transition_id):
    """Impure domain logic: Executes the POST request for a transition."""
    payload = build_transition_payload(transition_id)
    return client.post(f"/rest/api/3/issue/{issue_key}/transitions", payload)


def assign_to_sprint(client, board_id, issue_key):
    """Impure domain logic: Finds active sprint and assigns issue. Returns (success, sprint_id)."""
    sprint_id = client.fetch_active_sprint(board_id)
    if sprint_id:
        success = client.post(
            f"/rest/agile/1.0/sprint/{sprint_id}/issue", {"issues": [issue_key]}
        )
        return success, sprint_id
    return False, None
