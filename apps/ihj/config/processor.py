import re
from constants import C


def validate_config(raw_cfg):
    if "custom_fields" not in raw_cfg:
        raise ValueError("Missing 'custom_fields' configuration in config.yaml.")

    if "boards" not in raw_cfg or not raw_cfg["boards"]:
        raise ValueError("Missing 'boards' configuration in config.yaml.")

    available_keys = set(raw_cfg["custom_fields"].keys())
    board_template_keys = {"id", "name", "project_key", "team_uuid", "slug"}

    for slug, board in raw_cfg["boards"].items():
        # --- NEW: Validate types inside the board ---
        if "types" not in board or not board["types"]:
            raise ValueError(f"Board '{slug}' is missing 'types' array.")

        jql_templates = [board.get("jql", "")]
        jql_templates.extend(board.get("modes", {}).values())

        for template in jql_templates:
            if not template or not str(template).strip():
                if template == board.get("jql"):
                    raise ValueError(f"Board '{slug}' is missing a base 'jql' string.")
                continue

            found_vars = re.findall(r"\{(.*?)\}", template)
            for var in found_vars:
                if var not in available_keys and var not in board_template_keys:
                    raise ValueError(
                        f"JQL error in board '{slug}': '{var}' is not defined in "
                        "custom_fields or board metadata."
                    )
    return True


def parse_config(raw_cfg):
    formatted_cf = {}
    for key, val in raw_cfg["custom_fields"].items():
        formatted_cf[key] = f"cf[{val}]"
        formatted_cf[f"{key}_id"] = f"customfield_{val}"

    for board in raw_cfg["boards"].values():
        if "types" in board:
            board["type_order_map"] = {
                str(t.get("id")): (
                    int(t.get("order", 100)),
                    C.get(t.get("color", "reset"), C["reset"]),
                    bool(t.get("has_children", False)),
                )
                for t in board["types"]
            }

    return {
        **raw_cfg,
        "formatted_custom_fields": formatted_cf,
    }
