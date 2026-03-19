import re
from constants import C
from datetime import datetime


def format_date(date_str):
    """Pure: Converts Jira ISO timestamps to readable 'DD MMM YYYY' format."""
    if not date_str or date_str == "Unknown":
        return "Unknown"
    try:
        dt = datetime.strptime(date_str[:10], "%Y-%m-%d")
        return dt.strftime("%d %b %Y")
    except Exception:
        return date_str[:10]


def format_datetime(date_str):
    """Pure: Converts Jira ISO timestamps to readable 'DD MMM YYYY, HH:MM' format."""
    if not date_str or date_str == "Unknown":
        return "Unknown"
    try:
        # Jira format: 2024-03-24T14:30:00.000+0000
        # We grab the first 16 chars: "2024-03-24T14:30"
        dt = datetime.strptime(date_str[:16], "%Y-%m-%dT%H:%M")
        return dt.strftime("%d %b %Y, %H:%M")
    except Exception:
        return date_str[:16].replace("T", " ")


def wrap_text(text, width):
    """Wraps text cleanly, ignoring ANSI codes."""
    ansi_escape = re.compile(r"\x1b\[[0-9;]*m")
    wrapped_lines = []
    for line in text.split("\n"):
        if not line:
            wrapped_lines.append("")
            continue
        current_len, current_line = 0, ""
        words = re.split(r"([ \t]+)", line)
        for word in words:
            vis_len = len(ansi_escape.sub("", word))
            if current_len + vis_len > width and current_len > 0:
                if word.strip():
                    wrapped_lines.append(current_line.rstrip())
                    current_line, current_len = (
                        word.lstrip(),
                        len(ansi_escape.sub("", word.lstrip())),
                    )
            else:
                current_line += word
                current_len += vis_len
        if current_line:
            wrapped_lines.append(current_line.rstrip())
    return "\n".join(wrapped_lines)


def adf_to_ansi(node, wrap_width=90):
    """Converts ADF into ANSI formatted text."""
    if not node or not isinstance(node, dict):
        return ""
    nt, content = node.get("type"), node.get("content", [])
    res = ""

    if nt == "doc":
        for c in content:
            res += adf_to_ansi(c, wrap_width)

    elif nt == "paragraph":
        parts = [
            adf_to_ansi(c, wrap_width).strip()
            for c in content
            if adf_to_ansi(c, wrap_width).strip()
        ]
        if parts:
            res = wrap_text(" ".join(parts), wrap_width) + "\n\n"

    elif nt == "text":
        t = node.get("text", "")
        for m in node.get("marks", []):
            mt = m.get("type")
            if mt == "strong":
                t = f"{C['bold']}{t}{C['reset']}"
            elif mt == "em":
                t = f"{C['italic']}{t}{C['reset']}"
            elif mt == "code":
                t = f"{C['bg_gray']}{C['cyan']} {t} {C['reset']}"
            elif mt == "strike":
                t = f"{C['dim']}~{t}~{C['reset']}"
            elif mt == "link":
                href = m.get("attrs", {}).get("href", "")
                t = f"{C['blue']}\033[4m{t}\033[24m{C['reset']} {C['dim']}({href}){C['reset']}"
        res = t

    elif nt == "heading":
        inner = "".join([adf_to_ansi(c, wrap_width) for c in content]).strip()
        res = f"\n{C['cyan']}{C['bold']}{inner.upper()}{C['reset']}\n\n"

    elif nt in ["bulletList", "orderedList"]:
        items = [
            f"{i + 1 if nt == 'orderedList' else '•'} {adf_to_ansi(c, wrap_width).strip()}"
            for i, c in enumerate(content)
        ]
        res = "\n" + "\n".join(items) + "\n\n"

    elif nt == "listItem":
        res = "".join([adf_to_ansi(c, wrap_width) for c in content])

    elif nt == "codeBlock":
        lang = node.get("attrs", {}).get("language", "code").upper()
        code_text = "".join([c.get("text", "") for c in content])

        # Build a beautiful, un-wrapped terminal code block
        block = f"\n{C['bg_gray']}{C['bold']}   {lang} {C['reset']}\n"
        for line in code_text.split("\n"):
            line = line.replace("\t", "    ")
            block += f"{C['dim']}┃{C['reset']} {line}\n"
        res = block + "\n"

    return res


def get_priority_icon(prio):
    """Returns universally safe unicode icons for priorities."""
    p = prio.lower() if prio else ""
    if any(x in p for x in ["crit", "highest", "blocker"]):
        return f"{C['red']}{C['bold']}▲{C['reset']}"
    if any(x in p for x in ["major", "high"]):
        return f"{C['red']}▴{C['reset']}"
    if any(x in p for x in ["medium"]):
        return f"{C['yellow']}◆{C['reset']}"
    if any(x in p for x in ["minor", "low"]):
        return f"{C['blue']}▾{C['reset']}"
    if any(x in p for x in ["lowest", "trivial"]):
        return f"{C['cyan']}▼{C['reset']}"
    return f"{C['gray']}−{C['reset']}"


def get_status_style(status):
    """
    Universally safe unicode icons for statuses.
    Relies on color to do the heavy lifting for meaning.
    """
    s = status.lower()

    if any(x in s for x in ["done", "closed", "resolved", "complete"]):
        return C["green"], "✔"
    if any(x in s for x in ["block", "stop", "hold", "cancel"]):
        return C["red"], "✘"
    if any(x in s for x in ["review", "test", "qa", "verification"]):
        return C["magenta"], "◉"
    if any(x in s for x in ["progress", "doing", "active", "dev"]):
        return C["blue"], "▶"
    if any(x in s for x in ["refined", "ready", "approved"]):
        return C["cyan"], "★"
    if any(x in s for x in ["refinement", "grooming", "discovery", "triage"]):
        return C["yellow"], "⚙"
    return C["default"], "○"


def clean_issue_key(raw_string):
    """Strips ANSI escape sequences and standardizes the Jira issue key."""
    ansi_escape = re.compile(r"\x1b\[[0-9;]*m")
    return ansi_escape.sub("", raw_string).strip().upper()
