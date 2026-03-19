import os
import subprocess
import sys
import tempfile
import termios
import tty
import shutil

from constants import C


def notify_user(msg, title="Jira CLI", use_toast=False):
    """Sends a macOS desktop notification OR prints to console."""
    if use_toast:
        safe_msg = msg.replace("\\", "\\\\").replace('"', '\\"')
        safe_title = title.replace("\\", "\\\\").replace('"', '\\"')
        subprocess.run(
            [
                "osascript",
                "-e",
                f'display notification "{safe_msg}" with title "{safe_title}"',
            ]
        )
    else:
        # Standard CLI output
        print(f"\n{C['bold']}{C['cyan']}{title}:{C['reset']} {msg}\n")


def copy_to_clipboard(text):
    """Pipes text to macOS pbcopy."""
    p = subprocess.Popen(["pbcopy"], stdin=subprocess.PIPE)
    p.communicate(input=text.encode("utf-8"))


def get_terminal_width():
    """Returns the width of the current terminal window robustly."""
    return shutil.get_terminal_size((120, 24)).columns


def prompt_numeric_menu(options, title, color=C["blue"]):
    """Numeric TUI selector using raw mode."""
    fd = sys.stdin.fileno()
    old_settings = termios.tcgetattr(fd)
    try:
        tty.setraw(fd)
        sys.stdout.write("\033[?1049h\033[2J\033[H")
        sys.stdout.write(f"{C['bold']}{color} {title} {C['reset']}\r\n\r\n")
        for i, opt in enumerate(options):
            sys.stdout.write(f"  [{i + 1}] {opt}\r\n")
        sys.stdout.write(f"\r\n{C['dim']}Choice (q to cancel): {C['reset']}")
        sys.stdout.flush()

        while True:
            char = sys.stdin.read(1)
            if char == "q" or char == "\x1b":
                return None
            if char.isdigit():
                idx = int(char) - 1
                if 0 <= idx < len(options):
                    return idx
    finally:
        sys.stdout.write("\033[?1049l")
        termios.tcsetattr(fd, termios.TCSADRAIN, old_settings)


def launch_fzf(lines, board_name, mode_name, age, preview_path, bindings):
    """Executes the main FZF interface."""
    list_header = f"{C['bold']}{'ID':<12} P {'TYPE':<10} {'STATUS':<16} {'ASSIGNEE':<16} SUMMARY{C['reset']}"
    help_guide = f"{C['cyan']}Alt-R{C['reset']} Refresh | {C['cyan']}Alt-S{C['reset']} Mode | {C['cyan']}Alt-A{C['reset']} Assign | {C['cyan']}Alt-T{C['reset']} Transition | {C['cyan']}Alt-O{C['reset']} Open | {C['cyan']}Alt-E{C['reset']} Edit | {C['cyan']}Alt-C{C['reset']} Comment | {C['cyan']}Alt-N{C['reset']} Branch | {C['cyan']}Ctrl-N{C['reset']} New"

    fzf_cmd = [
        "fzf",
        "--header-lines=1",
        "--reverse",
        "--ansi",
        "--border",
        "--padding",
        "1,2",
        "--header",
        help_guide,
        "--border-label",
        f" {board_name} | {mode_name.upper()} ({age}s) ",
        "--preview",
        f"jq -r '.\"{ {1} }\"' {preview_path}",
        "--preview-window",
        "top:60%:wrap",
    ]

    for key, action in bindings.items():
        fzf_cmd.extend(["--bind", f"{key}:{action}"])

    subprocess.run(fzf_cmd, input="\n".join([list_header] + lines), text=True)


def open_in_editor(
    editor_cmd, initial_text, prefix="jira_", target_line=None, search_pattern=None
):
    """Writes text to tempfile, hands TTY to editor, reads back result."""
    fd, path = tempfile.mkstemp(prefix=prefix, suffix=".md")
    try:
        with os.fdopen(fd, "w") as f:
            f.write(initial_text)

        cmd = [editor_cmd]

        if any(v in editor_cmd.lower() for v in ["vim", "nvim", "vi"]):
            if search_pattern:
                cmd.extend(
                    ["-c", f"/{search_pattern}", "-c", "normal! $", "-c", "startinsert"]
                )
            elif target_line:
                cmd.extend([f"+{target_line}", "-c", "startinsert"])

        cmd.append(path)
        subprocess.run(cmd, check=True)

        with open(path, "r") as f:
            return f.read()
    finally:
        if os.path.exists(path):
            os.remove(path)
