def generate_frontmatter_schema(cfg, board_cfg):
    """Generates the JSON Schema dictionary with conditional logic for Sub-tasks."""
    types = [t["name"] for t in board_cfg.get("types", [])]
    transitions = board_cfg.get("transitions", [])

    properties = {
        "key": {"type": "string"},
        "summary": {"type": "string"},
        "type": {"type": "string", "enum": types},
        "priority": {
            "type": "string",
            "enum": ["Highest", "High", "Medium", "Low", "Lowest"],
        },
        "status": {"type": "string", "enum": transitions}
        if transitions
        else {"type": "string"},
        "parent": {"type": "string"},
        "sprint": {"type": "boolean"},
    }

    for cf_name in cfg.get("custom_fields", {}).keys():
        if cf_name == "team":
            properties["team"] = {"type": ["boolean", "string"]}
        else:
            properties[cf_name] = {"type": "string"}

    schema = {
        "$schema": "http://json-schema.org/draft-07/schema#",
        "type": "object",
        "properties": properties,
        "required": ["summary", "type"],
        "allOf": [
            {
                "if": {"properties": {"type": {"const": "Sub-task"}}},
                "then": {"required": ["parent"]},
            }
        ],
    }

    return schema


def build_frontmatter_doc(schema_path, metadata, body_text):
    """Pure: Constructs the final markdown string with the YAML block."""
    lines = ["---", f"# yaml-language-server: $schema=file://{schema_path}"]

    # 1. Prioritize core fields at the top for UX
    order = ["key", "type", "priority", "status", "parent"]
    for k in order:
        val = metadata.get(k)
        if val:
            lines.append(f'{k}: "{val}"' if k != "key" else f"key: {val}")

    # 2. Inject custom fields
    for k, v in metadata.items():
        if k not in order and k != "summary" and v is not None and v != "":
            if str(v).lower() in ("true", "false"):
                lines.append(f"{k}: {str(v).lower()}")
            else:
                lines.append(f'{k}: "{v}"')

    # 3. Always put summary last so it touches the body block
    if "summary" in metadata:
        lines.append(f'summary: "{metadata["summary"]}"')

    lines.extend(["---", "", body_text])
    return "\n".join(lines)
