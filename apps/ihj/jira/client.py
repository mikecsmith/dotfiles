import json
import urllib.request
import urllib.error


def search_jira(server, token, payload):
    """Impure: Executes the search POST request."""
    url = f"{server}/rest/api/3/search/jql"
    req = urllib.request.Request(url, data=json.dumps(payload).encode(), method="POST")
    req.add_header("Authorization", f"Basic {token}")
    req.add_header("Content-Type", "application/json")

    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read().decode())
    except urllib.error.HTTPError as e:
        err_body = e.read().decode()
        raise RuntimeError(f"Jira API Error ({e.code}): {err_body}")


def fetch_transitions(server, token, issue_key):
    """Impure: GET transitions."""
    url = f"{server}/rest/api/3/issue/{issue_key}/transitions"
    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Basic {token}")
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read().decode()).get("transitions", [])
    except Exception:
        return []


def fetch_myself_api(server, token):
    """Impure: GET current user info (raw API call)."""
    url = f"{server}/rest/api/3/myself"
    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Basic {token}")
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read().decode())


def update_issue(server, token, endpoint, payload, method="POST"):
    """Impure: POST/PUT for transitions, creations, or assignments."""
    url = f"{server}/rest/api/3/{endpoint}"
    req = urllib.request.Request(url, data=json.dumps(payload).encode(), method=method)
    req.add_header("Authorization", f"Basic {token}")
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as response:
            body = response.read().decode()
            if body:
                return json.loads(body)
            return True
    except Exception as e:
        print(f"API Error: {e}")
        return False


def fetch_active_sprint(server, token, board_id):
    """Impure: GET active sprint for a board via Agile API."""
    url = f"{server}/rest/agile/1.0/board/{board_id}/sprint?state=active"
    req = urllib.request.Request(url)
    req.add_header("Authorization", f"Basic {token}")
    try:
        with urllib.request.urlopen(req) as r:
            data = json.loads(r.read().decode())
            values = data.get("values", [])
            if values:
                return values[0].get("id")
    except Exception as e:
        print(f"Sprint Fetch Error: {e}")
    return None


def add_to_sprint(server, token, sprint_id, issue_key):
    """Impure: POST issue to sprint via Agile API."""
    url = f"{server}/rest/agile/1.0/sprint/{sprint_id}/issue"
    payload = {"issues": [issue_key]}
    req = urllib.request.Request(url, data=json.dumps(payload).encode(), method="POST")
    req.add_header("Authorization", f"Basic {token}")
    req.add_header("Content-Type", "application/json")
    try:
        urllib.request.urlopen(req)
        return True
    except Exception as e:
        print(f"Sprint Add Error: {e}")
        return False
