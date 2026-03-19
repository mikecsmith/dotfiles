import json
from datetime import datetime, timezone


def save_export_state(slug, state_dict):
    """Writes the current hash map to a hidden state file."""
    filename = f".{slug}.state.json"
    try:
        with open(filename, "w") as f:
            json.dump(state_dict, f, indent=2)
    except IOError as e:
        print(f"Warning: Could not save state file: {e}")


def write_export_output(output_dict):
    """Finalizes the story by printing the JSON payload to stdout."""
    print(json.dumps(output_dict, indent=2))


def build_metadata(slug, board_cfg):
    """Pure helper to wrap the export with context."""
    return {
        "board_slug": slug,
        "project_key": board_cfg.get("project_key"),
        "exported_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
    }
