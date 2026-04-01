-- Deep hover: chains typeDefinition hover underneath thin initial hovers.
-- When the initial hover is just a type signature (e.g. `var ws *core.Workspace`),
-- fetches the hover for the referenced type and appends it below a separator.
-- Used by K keymap and auto-hover plugin.

local hover_opts = { max_width = 80, max_height = 25 }

local function extract_value(contents)
  if type(contents) == "string" then
    return contents
  end
  return contents.value or ""
end

local function count_content_lines(value)
  local count = 0
  for _, line in ipairs(vim.split(value, "\n")) do
    if not line:match("^```") and line:match("%S") then
      count = count + 1
    end
  end
  return count
end

--- Render a hover result in a floating window
local function show_hover(result)
  local value = extract_value(result.contents)
  local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
  if vim.tbl_isempty(lines) then
    return
  end
  vim.lsp.util.open_floating_preview(lines, "markdown", hover_opts)
end

--- Perform a deep hover request.
--- If `callback` is provided, calls it with the result instead of showing.
local function request(bufnr, min_lines, callback)
  local render = callback or show_hover
  local params = vim.lsp.util.make_position_params(0, "utf-16")

  vim.lsp.buf_request(bufnr, "textDocument/hover", params, function(err, result)
    if err or not result or not result.contents then
      return
    end

    local value = extract_value(result.contents)
    local content_lines = count_content_lines(value)

    -- Rich hover — show as-is
    if content_lines >= min_lines then
      render(result)
      return
    end

    -- Thin hover — chain the type definition's hover
    vim.lsp.buf_request(bufnr, "textDocument/typeDefinition", params, function(td_err, td_result)
      if td_err or not td_result or vim.tbl_isempty(td_result) then
        if content_lines > 0 then
          render(result)
        end
        return
      end

      local target = vim.islist(td_result) and td_result[1] or td_result
      local uri = target.uri or target.targetUri
      local range = target.range or target.targetSelectionRange

      if not uri or not range then
        if content_lines > 0 then
          render(result)
        end
        return
      end

      local type_params = {
        textDocument = { uri = uri },
        position = range.start,
      }

      vim.lsp.buf_request(bufnr, "textDocument/hover", type_params, function(th_err, th_result)
        if th_err or not th_result or not th_result.contents then
          if content_lines > 0 then
            render(result)
          end
          return
        end

        -- Combine: original signature + --- + type docs
        render({
          contents = {
            kind = "markdown",
            value = extract_value(result.contents) .. "\n\n---\n\n" .. extract_value(th_result.contents),
          },
        })
      end)
    end)
  end)
end

return {
  {
    "deep-hover",
    virtual = true,
    event = "LspAttach",
    keys = {
      {
        "K",
        function()
          request(0, 2)
        end,
        desc = "Hover (deep)",
      },
    },
    config = function()
      _G.deep_hover_request = request
    end,
  },
}
