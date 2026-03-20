import json
import urllib.request
import urllib.error
from typing import Optional, Union


class JiraClient:
    def __init__(self, server: str, token: str):
        self.server = server.rstrip("/")
        self.token = token

    def _build_request(
        self, path: str, payload: Optional[dict] = None, method: str = "GET"
    ) -> urllib.request.Request:
        """Private helper to build the HTTP request with standard Jira headers."""
        url = f"{self.server}{path}"
        data = json.dumps(payload).encode() if payload else None

        req = urllib.request.Request(url, data=data, method=method)
        req.add_header("Authorization", f"Basic {self.token}")

        if payload is not None or method in ["POST", "PUT"]:
            req.add_header("Content-Type", "application/json")

        return req

    def _execute_mutation(
        self, path: str, payload: dict, method: str
    ) -> Union[dict, bool]:
        """Generic execution for POST/PUT requests."""
        req = self._build_request(path, payload=payload, method=method)
        try:
            with urllib.request.urlopen(req) as response:
                body = response.read().decode()
                if body:
                    return json.loads(body)
                return True
        except urllib.error.HTTPError as e:
            err_body = e.read().decode()
            print(f"API Error ({e.code}): {err_body}")
            return False
        except Exception as e:
            print(f"Network Error: {e}")
            return False

    def post(self, path: str, payload: dict) -> Union[dict, bool]:
        """Generic POST."""
        return self._execute_mutation(path, payload, "POST")

    def put(self, path: str, payload: dict) -> Union[dict, bool]:
        """Generic PUT."""
        return self._execute_mutation(path, payload, "PUT")

    def search_issues(self, payload: dict) -> dict:
        """Executes the search POST request."""
        req = self._build_request(
            "/rest/api/3/search/jql", payload=payload, method="POST"
        )
        try:
            with urllib.request.urlopen(req) as r:
                return json.loads(r.read().decode())
        except urllib.error.HTTPError as e:
            err_body = e.read().decode()
            raise RuntimeError(f"Jira API Error ({e.code}): {err_body}")

    def fetch_transitions(self, issue_key: str) -> list:
        """GET transitions for a specific issue."""
        req = self._build_request(f"/rest/api/3/issue/{issue_key}/transitions")
        try:
            with urllib.request.urlopen(req) as r:
                return json.loads(r.read().decode()).get("transitions", [])
        except Exception:
            return []

    def fetch_myself(self) -> dict:
        """GET current user info."""
        req = self._build_request("/rest/api/3/myself")
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read().decode())

    def fetch_active_sprint(self, board_id: str) -> Optional[str]:
        """GET active sprint for a board via Agile API."""
        req = self._build_request(
            f"/rest/agile/1.0/board/{board_id}/sprint?state=active"
        )
        try:
            with urllib.request.urlopen(req) as r:
                data = json.loads(r.read().decode())
                values = data.get("values", [])
                if values:
                    return values[0].get("id")
        except Exception as e:
            print(f"Sprint Fetch Error: {e}")
        return None
