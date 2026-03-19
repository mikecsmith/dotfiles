import os
import json
import subprocess


def load_raw_config_file(path):
    """Locates and reads the YAML file into a raw dict. No logic."""
    if not os.path.exists(path):
        raise FileNotFoundError(f"Config not found at {path}")

    cmd = ["yq", "eval", "-o=json", path]
    return json.loads(subprocess.check_output(cmd, text=True))


def parse_yaml_string(yaml_str):
    """Pipes a YAML string through yq to return a Python dict."""
    if not yaml_str:
        return {}
    cmd = ["yq", "eval", "-o=json", "-"]
    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
    out, _ = p.communicate(input=yaml_str)
    return json.loads(out)
