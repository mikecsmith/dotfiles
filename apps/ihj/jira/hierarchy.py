from export.markdown import adf_to_markdown
from export.idempotency import generate_issue_hash


def build_export_hierarchy(raw_issues):
    """Pure: Logic for nesting parents/children and hashing every node."""
    registry = {}
    state_dict = {}

    for issue in raw_issues:
        key = issue["key"]
        f = issue.get("fields", {})

        issue_data = {
            "key": key,
            "type": f.get("issuetype", {}).get("name", "Unknown"),
            "summary": f.get("summary", ""),
            "status": f.get("status", {}).get("name", ""),
            "description": adf_to_markdown(f.get("description")).strip(),
            "children": [],
        }

        state_dict[key] = generate_issue_hash(issue_data)
        registry[key] = {
            "data": issue_data,
            "parent": (f.get("parent") or {}).get("key"),
        }

    roots = []
    for key, item in registry.items():
        pk = item["parent"]
        if pk and pk in registry:
            registry[pk]["data"]["children"].append(item["data"])
        else:
            roots.append(item["data"])

    return roots, state_dict
