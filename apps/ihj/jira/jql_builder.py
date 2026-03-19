def build_jql(board_cfg, mode, custom_field_map):
    """
    Constructs the JQL string safely.
    Acts as a final safety gate against empty queries.
    """
    base_filter = board_cfg.get("jql", "")

    # CRITICAL SAFETY CHECK: Refuse to continue if base JQL is missing
    if not base_filter or not str(base_filter).strip():
        raise ValueError(
            f"Board '{board_cfg.get('slug')}' has no base JQL. Operation aborted for safety."
        )

    format_vars = {**custom_field_map, **board_cfg}

    mode_filter = board_cfg.get("modes", {}).get(mode, "")

    base_jql = base_filter.format(**format_vars)
    mode_jql = mode_filter.format(**format_vars) if mode_filter else ""

    if mode_jql:
        return f"{base_jql} AND ({mode_jql})"

    return base_jql
