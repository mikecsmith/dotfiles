local M = {}

M.toggle_chars = {
  '"',
  "'",
  "`",
  "<",
  ">",
  "{",
  "}",
  "[",
  "]",
  "(",
  ")",
  " ",
  "",
}

-- This function toggles the ghost_text setting based on the users context
function M.toggle_ghost_text()
  if vim.api.nvim_get_mode().mode ~= "i" then
    return
  end

  local cursor_col = vim.fn.col(".") -- Get cursor column
  local line = vim.fn.getline(".") -- Get current line content
  local char_after = line:sub(cursor_col, cursor_col)
  local should_enable_ghost_text = vim.tbl_contains(M.toggle_chars, char_after)

  local cmp_config = require("cmp.config")
  if should_enable_ghost_text then
    cmp_config.set_onetime({
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },
    })
  else
    cmp_config.set_onetime({
      experimental = {
        ghost_text = false,
      },
    })
  end
end

-- Utility method to filter out the buffer & copilot sources, remove text completions from LSP, and apply stricter matching rules to some sources
function M.process_sources(sources)
  local types = require("cmp.types")
  local matcher = require("cmp.matcher")

  local processed_sources = vim.tbl_map(function(source)
    if source.name == "buffer" then
      return nil
    elseif source.name == "copilot" then
      return nil
    elseif source.name == "nvim_lsp" then
      return vim.tbl_deep_extend("force", source, {
        ---@param entry cmp.Entry
        entry_filter = function(entry, _)
          local kind = types.lsp.CompletionItemKind[entry:get_kind()]
          if kind == "Text" then
            return false
          end
          return true
        end,
      })
    elseif source.name == "snippets" then
      return vim.tbl_deep_extend("force", source, {
        ---@param entry cmp.Entry
        ---@param ctx cmp.Context
        entry_filter = function(entry, ctx)
          local input = vim.trim(ctx.cursor_before_line)
          local word = entry.completion_item.label

          local score = matcher.match(input, word, {
            disallow_fuzzy_matching = true,
            disallow_partial_matching = true,
            disallow_prefix_unmatching = true,
            disallow_fullfuzzy_matching = true,
            disallow_partial_fuzzy_matching = true,
            disallow_symbol_nonprefix_matching = true,
          })
          return score > 0
        end,
      })
    end
    return source
  end, sources or {})

  return vim.tbl_filter(function(source)
    return source ~= nil
  end, processed_sources)
end

return M
