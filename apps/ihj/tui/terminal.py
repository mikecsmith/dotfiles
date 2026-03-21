import os
import subprocess
import sys
import shutil

from constants import C


def notify_user(msg, title="Jira CLI", use_toast=False):
    """Sends a desktop notification (macOS/Linux) OR prints to console."""
    if use_toast:
        safe_msg = msg.replace("\\", "\\\\").replace('"', '\\"')
        safe_title = title.replace("\\", "\\\\").replace('"', '\\"')

        platform = getattr(sys, "platform", "")

        if platform == "darwin":
            script = f'display notification "{safe_msg}" with title "{safe_title}" sound name "Glass"'
            try:
                subprocess.run(["osascript", "-e", script], check=False)
            except Exception:
                pass
        elif platform.startswith("linux"):
            if shutil.which("notify-send"):
                try:
                    subprocess.run(["notify-send", safe_title, safe_msg], check=False)
                except Exception:
                    pass
    else:
        print(f"\n{C['bold']}{C['cyan']}{title}:{C['reset']} {msg}\n")


def copy_to_clipboard(text):
    """Pipes text to the system clipboard gracefully across OSs."""
    cmds = []

    platform = getattr(sys, "platform", "")

    if platform == "darwin":
        cmds = [["pbcopy"]]
    elif platform.startswith("linux"):
        cmds = [
            ["wl-copy"],
            ["xclip", "-selection", "clipboard"],
            ["xsel", "--clipboard", "--input"],
        ]

    for cmd in cmds:
        if shutil.which(cmd[0]):
            try:
                p = subprocess.Popen(cmd, stdin=subprocess.PIPE)
                p.communicate(input=text.encode("utf-8"))
                return
            except Exception:
                pass


def get_terminal_width():
    """Returns the width of the current terminal window robustly."""
    return shutil.get_terminal_size((120, 24)).columns


def prompt_numeric_menu(options, title, color=C["blue"], subtitle=None):
    """Numeric TUI selector using standard error to safely support piping stdout."""
    try:
        sys.stderr.write("\033[?1049h\033[2J\033[H")
        sys.stderr.write(f"{C['bold']}{color} {title} {C['reset']}\n")

        if subtitle:
            sys.stderr.write(f"\n{subtitle}\n")

        sys.stderr.write("\n")

        for i, opt in enumerate(options):
            sys.stderr.write(f"  [{i + 1}] {opt}\n")

        sys.stderr.flush()

        while True:
            # Print the prompt to STDERR so it doesn't get captured in pipes
            sys.stderr.write(
                f"\n{C['dim']}Choice (q to cancel, enter to confirm): {C['reset']}"
            )
            sys.stderr.flush()

            # Read the user's input directly from STDIN
            choice = sys.stdin.readline().strip().lower()

            if choice == "q":
                return None

            if choice.isdigit():
                idx = int(choice) - 1
                if 0 <= idx < len(options):
                    return idx

            sys.stderr.write(
                f"{C['red']}Invalid choice. Please select 1-{len(options)}.{C['reset']}\n"
            )

    except (KeyboardInterrupt, EOFError):
        return None
    finally:
        sys.stderr.write("\033[?1049l")
        sys.stderr.flush()


def launch_fzf(lines, board_name, mode_name, age, preview_path, bindings):
    """Executes the main FZF interface."""
    list_header = f"{C['bold']}{'ID':<12} P {'TYPE':<10} {'STATUS':<16} {'ASSIGNEE':<16} SUMMARY{C['reset']}"
    help_guide = f"{C['cyan']}Alt-R{C['reset']} Refresh | {C['cyan']}Alt-F{C['reset']} Filter | {C['cyan']}Alt-A{C['reset']} Assign | {C['cyan']}Alt-T{C['reset']} Transition | {C['cyan']}Alt-O{C['reset']} Open | {C['cyan']}Alt-E{C['reset']} Edit | {C['cyan']}Alt-C{C['reset']} Comment | {C['cyan']}Alt-N{C['reset']} Branch | {C['cyan']}Ctrl-N{C['reset']} New"

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

    fzf_env = os.environ.copy()
    fzf_env["IHJ_IS_FZF"] = "1"

    subprocess.run(
        fzf_cmd,
        input="\n".join([list_header] + lines),
        text=True,
        env=fzf_env,
    )
