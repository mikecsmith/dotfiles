import re


def adf_to_markdown(node):
    """Recursively converts Jira ADF into standard Markdown."""
    if not node or not isinstance(node, dict):
        return ""
    nt, content = node.get("type"), node.get("content", [])
    res = ""

    if nt == "doc":
        for c in content:
            res += adf_to_markdown(c)
    elif nt == "paragraph":
        parts = [
            adf_to_markdown(c).strip() for c in content if adf_to_markdown(c).strip()
        ]
        if parts:
            res = " ".join(parts) + "\n\n"
    elif nt == "text":
        t = node.get("text", "")
        link_href = None

        for m in node.get("marks", []):
            mt = m.get("type")
            if mt == "strong":
                t = f"**{t}**"
            elif mt == "em":
                t = f"*{t}*"
            elif mt == "code":
                t = f"`{t}`"
            elif mt == "strike":
                t = f"~~{t}~~"
            elif mt == "link":
                link_href = m.get("attrs", {}).get("href", "")

        if link_href:
            t = f"[{t}]({link_href})"

        res = t
    elif nt == "heading":
        level = node.get("attrs", {}).get("level", 2)
        inner = "".join([adf_to_markdown(c) for c in content]).strip()
        res = f"\n{'#' * level} {inner}\n\n"
    elif nt == "listItem":
        res = "".join([adf_to_markdown(c) for c in content]).strip()
    elif nt in ["bulletList", "orderedList"]:
        items = [f"- {adf_to_markdown(c).strip()}" for c in content]
        res = "\n" + "\n".join(items) + "\n\n"
    elif nt == "codeBlock":
        lang = node.get("attrs", {}).get("language", "")
        code_text = "".join([c.get("text", "") for c in content])
        res = f"\n```{lang}\n{code_text}\n```\n\n"
    return res


def _parse_inline_text(text, inherited_marks=None):
    """
    Pure: Recursively parses flat text for inline markdown and nested marks.
    Inherits marks (e.g., bold, link) as it dives deeper into nested syntax.
    """
    if inherited_marks is None:
        inherited_marks = []

    nodes = []

    # Priority matters here: Bold (** or __) must be checked before Italic (* or _)
    pattern = re.compile(
        r"(\*\*(.*?)\*\*|__(.*?)__)|"  # Groups 1,2,3: Bold
        r"(\*(.*?)\*|_(.*?)_)|"  # Groups 4,5,6: Italic
        r"(~~(.*?)~~)|"  # Groups 7,8: Strike
        r"(`(.*?)`)|"  # Groups 9,10: Code
        r"(\[(.*?)\]\((.*?)\))"  # Groups 11,12,13: Link
    )

    pos = 0
    for m in pattern.finditer(text):
        if m.start() > pos:
            nodes.append(
                {
                    "type": "text",
                    "text": text[pos : m.start()],
                    "marks": list(inherited_marks),
                }
            )

        new_marks = list(inherited_marks)
        inner_text = ""

        if m.group(1):  # Bold
            new_marks.append({"type": "strong"})
            inner_text = m.group(2) if m.group(2) is not None else m.group(3)
            nodes.extend(_parse_inline_text(inner_text, new_marks))

        elif m.group(4):  # Italic
            new_marks.append({"type": "em"})
            inner_text = m.group(5) if m.group(5) is not None else m.group(6)
            nodes.extend(_parse_inline_text(inner_text, new_marks))

        elif m.group(7):  # Strike
            new_marks.append({"type": "strike"})
            inner_text = m.group(8)
            nodes.extend(_parse_inline_text(inner_text, new_marks))

        elif m.group(9):  # Code (We don't parse inside code blocks)
            new_marks.append({"type": "code"})
            inner_text = m.group(10)
            nodes.append({"type": "text", "text": inner_text, "marks": new_marks})

        elif m.group(11):  # Link
            new_marks.append({"type": "link", "attrs": {"href": m.group(13)}})
            inner_text = m.group(12)
            nodes.extend(_parse_inline_text(inner_text, new_marks))

        pos = m.end()

    # 3. Append any trailing plain text
    if pos < len(text):
        nodes.append(
            {"type": "text", "text": text[pos:], "marks": list(inherited_marks)}
        )

    # 4. Clean up empty nodes and strip empty marks arrays for Jira
    final_nodes = []
    for n in nodes:
        if n["text"]:  # Ignore empty strings
            if not n.get("marks"):
                n.pop("marks", None)
            final_nodes.append(n)

    return final_nodes if final_nodes else [{"type": "text", "text": text}]


def markdown_to_adf(md_text):
    """Converts Markdown back into Jira ADF dicts, mapping symmetric elements."""
    if not md_text or not md_text.strip():
        return {"version": 1, "type": "doc", "content": []}

    code_blocks = {}

    def code_replacer(match):
        placeholder = f"__CODE_BLOCK_{len(code_blocks)}__"
        lang = match.group(1).strip()
        code = match.group(2).strip()
        code_blocks[placeholder] = (lang, code)
        return f"\n\n{placeholder}\n\n"

    md_text = re.sub(r"```(.*)\n([\s\S]*?)```", code_replacer, md_text)

    blocks = md_text.strip().split("\n\n")
    content = []

    for block in blocks:
        block = block.strip()
        if not block:
            continue

        if block in code_blocks:
            lang, code = code_blocks[block]
            content.append(
                {
                    "type": "codeBlock",
                    "attrs": {"language": lang or "plain"},
                    "content": [{"type": "text", "text": code}],
                }
            )
        elif block.startswith("#"):
            m = re.match(r"^(#{1,6})\s+(.*)", block)
            if m:
                level = len(m.group(1))
                text = m.group(2)
                content.append(
                    {
                        "type": "heading",
                        "attrs": {"level": level},
                        "content": _parse_inline_text(text),
                    }
                )
        elif (
            block.startswith("- ")
            or block.startswith("* ")
            or re.match(r"^\d+\.\s+", block)
        ):
            items = []
            for line in block.split("\n"):
                line = line.strip()
                if not line:
                    continue
                clean_line = re.sub(r"^([-*]|\d+\.)\s+", "", line)
                items.append(
                    {
                        "type": "listItem",
                        "content": [
                            {
                                "type": "paragraph",
                                "content": _parse_inline_text(clean_line),
                            }
                        ],
                    }
                )

            is_ordered = bool(re.match(r"^\d+\.", block))
            content.append(
                {
                    "type": "orderedList" if is_ordered else "bulletList",
                    "content": items,
                }
            )
        else:
            content.append({"type": "paragraph", "content": _parse_inline_text(block)})

    return {"version": 1, "type": "doc", "content": content}


def split_frontmatter_and_body(raw_text):
    """Separates the YAML block string from the Markdown body string."""
    parts = raw_text.split("---", 2)
    if len(parts) < 3:
        return "", raw_text.strip()
    return parts[1].strip(), parts[2].strip()
