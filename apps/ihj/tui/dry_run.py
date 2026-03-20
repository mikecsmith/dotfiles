import json
from constants import C


def print_dry_run(title, data=None, message=None):
    """Standardized visual block for dry runs."""
    print(f"\n{C['bg_gray']}{C['bold']}{C['cyan']} 🚧 DRY RUN: {title} 🚧 {C['reset']}")
    if message:
        print(f"{C['dim']}{message}{C['reset']}")
    if data:
        print(json.dumps(data, indent=2))
