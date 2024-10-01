-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("fathom_" .. name, { clear = true })
end

-- Toggle cmp ghost text based on insert and cusor movement
vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI" }, {
  group = augroup("cmp_toggle_ghost_text"),
  callback = require("fathom.cmp").toggle_ghost_text,
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.fn.winnr("$") > 1 then
      return
    end

    if vim.bo.filetype == "neo-tree" then
      vim.cmd("quit")
    end
  end,
})
