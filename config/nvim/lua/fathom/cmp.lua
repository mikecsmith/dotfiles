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

return M
