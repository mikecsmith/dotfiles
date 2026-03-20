import os
import sys
from pathlib import Path

from config.io import load_raw_config_file
from config.processor import validate_config, parse_config
from config.cli import parse_args
from constants import C


def initialize_app():
    """Bootstraps the entire application state."""

    # 1. Setup Paths
    config_dir = os.path.expanduser("~/.config/ihj")
    cache_dir = os.path.expanduser("~/.local/state/ihj")
    Path(config_dir).mkdir(parents=True, exist_ok=True)
    Path(cache_dir).mkdir(parents=True, exist_ok=True)

    # 2. Require Token
    token = os.environ.get("JIRA_BEARER_TOKEN")
    if not token:
        print(
            f"\n{C['red']}{C['bold']}Error:{C['reset']} JIRA_BEARER_TOKEN environment variable not set."
        )
        sys.exit(1)

    # 3. Process YAML
    try:
        raw_cfg = load_raw_config_file(f"{config_dir}/config.yaml")
        validate_config(raw_cfg)
        cfg = parse_config(raw_cfg)
    except Exception as e:
        sys.exit(f"Setup Error: {e}")

    # 4. Parse Args & Env
    args = parse_args()
    use_toast = os.environ.get("IHJ_IS_FZF") == "1"

    # Return a unified dictionary of context
    return {
        "args": args,
        "cfg": cfg,
        "token": token,
        "use_toast": use_toast,
        "cache_dir": cache_dir,
        "executable": sys.argv[0],
    }
