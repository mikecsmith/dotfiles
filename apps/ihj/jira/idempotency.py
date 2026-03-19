import json
import hashlib


def generate_issue_hash(issue_data):
    """Pure: Deterministic hash for change detection."""
    # We remove 'children' from the hash so child changes don't flag the parent as 'dirty'
    hash_copy = {k: v for k, v in issue_data.items() if k != "children"}
    payload = json.dumps(hash_copy, sort_keys=True).encode("utf-8")
    return hashlib.sha256(payload).hexdigest()
