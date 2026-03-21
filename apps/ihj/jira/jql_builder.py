import re


def build_jql(board_cfg, filter_name, custom_field_map):
    base_filter = board_cfg.get("jql", "")

    if not base_filter or not str(base_filter).strip():
        raise ValueError(f"Board '{board_cfg.get('slug')}' has no base JQL.")

    format_vars = {**custom_field_map, **board_cfg}

    target_filter = board_cfg.get("filters", {}).get(filter_name, "")

    base_jql = base_filter.format(**format_vars)
    injected_jql = target_filter.format(**format_vars) if target_filter else ""

    if injected_jql:
        parts = re.split(r"\s+ORDER\s+BY\s+", base_jql, maxsplit=1, flags=re.IGNORECASE)

        if len(parts) > 1:
            query_part = parts[0]
            order_part = f" ORDER BY {parts[1]}"
            return f"({query_part}) AND ({injected_jql}){order_part}"

        return f"({base_jql}) AND ({injected_jql})"

    return base_jql
