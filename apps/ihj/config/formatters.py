import re


def strip_ansi(raw_string):
    """Generic middleware to strip terminal colors from inputs."""
    ansi_escape = re.compile(r"\x1b\[[0-9;]*m")
    return ansi_escape.sub("", str(raw_string)).strip()


def clean_issue_key(raw_string):
    """Standardizes the Jira issue key format."""
    return strip_ansi(raw_string).upper()
