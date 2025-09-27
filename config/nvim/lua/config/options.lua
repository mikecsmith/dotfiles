-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.filetype.add({
  filename = {
    ["Tiltfile"] = "tiltfile",
  },
  pattern = {
    ["Tiltfile.*"] = "tiltfile",
  },
})

vim.g.ai_cmp = false
vim.g.lazyvim_blink_main = true
