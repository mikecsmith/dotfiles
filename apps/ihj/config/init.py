import os
import sys
from pathlib import Path

from config.io import load_raw_config_file
from config.processor import validate_config, parse_config
from config.cli import parse_args
from constants import C


def initialize_app():
    """Initialize the entire application state."""

    config_dir = os.path.expanduser("~/.config/ihj")
    cache_dir = os.path.expanduser("~/.local/state/ihj")
    Path(config_dir).mkdir(parents=True, exist_ok=True)
    Path(cache_dir).mkdir(parents=True, exist_ok=True)

    args = parse_args()
    use_toast = os.environ.get("IHJ_IS_FZF") == "1"

    token = os.environ.get("JIRA_BEARER_TOKEN")
    if not token:
        print(
            f"\n{C['red']}{C['bold']}Error:{C['reset']} JIRA_BEARER_TOKEN environment variable not set."
        )
        sys.exit(1)

    config_path = f"{config_dir}/config.yaml"
    is_bootstrap = args.command == "bootstrap"

    try:
        raw_cfg = load_raw_config_file(config_path)
        if raw_cfg is None:
            raw_cfg = {}
    except FileNotFoundError:
        if is_bootstrap:
            raw_cfg = {}  # Allow empty config for bootstrapping
        else:
            sys.exit(
                f"\n{C['red']}Setup Error: Config not found at {config_path}. Run 'ihj bootstrap <PROJECT>' first.{C['reset']}"
            )
    except Exception as e:
        sys.exit(f"\n{C['red']}Setup Error: Failed to parse config - {e}{C['reset']}")

    if is_bootstrap:
        cfg = raw_cfg
        # If there's no server configured, safely prompt the user on stderr
        if not cfg.get("server"):
            sys.stderr.write(
                f"\n{C['cyan']}No Jira server found in configuration.{C['reset']}\n"
            )
            sys.stderr.write(
                f"{C['dim']}Enter Jira Server URL (e.g., https://company.atlassian.net): {C['reset']}"
            )
            sys.stderr.flush()
            cfg["server"] = sys.stdin.readline().strip()

            if not cfg["server"]:
                sys.exit(
                    f"\n{C['red']}Error: Server URL is required to connect to Jira.{C['reset']}"
                )

            # Flag that this was a fresh setup so we can scaffold the root keys
            cfg["_prompted_for_server"] = True
    else:
        # Strict validation for all normal commands
        try:
            validate_config(raw_cfg)
            cfg = parse_config(raw_cfg)
        except Exception as e:
            sys.exit(f"\n{C['red']}Setup Error: {e}{C['reset']}")

    return {
        "args": args,
        "cfg": cfg,
        "token": token,
        "use_toast": use_toast,
        "cache_dir": cache_dir,
        "executable": sys.argv[0],
    }
