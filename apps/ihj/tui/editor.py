import os
import subprocess
import sys
import tempfile
import shlex


def calculate_cursor_target(initial_doc, summary_val):
    """Determines where an editor should place the cursor."""
    if not summary_val:
        return None, "^summary:"

    dash_count = 0
    for idx, line in enumerate(initial_doc.split("\n")):
        if line.strip() == "---":
            dash_count += 1
            if dash_count == 2:
                return idx + 2, None

    return None, None


def open_in_editor(
    editor_cmd, initial_text, prefix="jira_", target_line=None, search_pattern=None
):
    """Writes text to tempfile, hands TTY to editor, reads back result."""

    cmd = shlex.split(editor_cmd) if editor_cmd else []
    if not cmd:
        cmd = ["vim"]

    base_editor = os.path.basename(cmd[0]).lower()

    if any(v in base_editor for v in ["vim", "nvim", "vi"]):
        if search_pattern:
            cmd.extend(
                ["-c", f"/{search_pattern}", "-c", "normal! $", "-c", "startinsert"]
            )
        elif target_line:
            cmd.extend([f"+{target_line}", "-c", "startinsert"])
        else:
            cmd.extend(["-c", "startinsert"])

    fd, path = tempfile.mkstemp(prefix=prefix, suffix=".md")
    cmd.append(path)

    try:
        with os.fdopen(fd, "w") as f:
            f.write(initial_text)

        subprocess.run(cmd, check=True, stdin=sys.stdin, stdout=sys.stdout)

        with open(path, "r") as f:
            return f.read()

    except subprocess.CalledProcessError as e:
        print(f"Editor Error: {e}")
        return ""
    except FileNotFoundError:
        print(
            f"Error: Could not find editor '{cmd[0]}'. Is it installed and in your PATH?"
        )
        return ""
    finally:
        if os.path.exists(path):
            os.remove(path)
