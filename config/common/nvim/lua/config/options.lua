-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Rounded borders on all floating windows (hover, signature, diagnostics, etc.)
vim.o.winborder = "rounded"

-- Disable spellcheck in LSP floating previews (hover, signature, etc.)
local orig_open_floating_preview = vim.lsp.util.open_floating_preview
vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  local bufnr, winnr = orig_open_floating_preview(contents, syntax, opts, ...)
  if winnr and vim.api.nvim_win_is_valid(winnr) then
    vim.wo[winnr].spell = false
  end
  return bufnr, winnr
end

-- Folding: use treesitter by default, upgrade to LSP when available
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldtext = "" -- use default text (shows first line of fold)
vim.o.foldlevel = 99 -- start with all folds open
vim.o.foldlevelstart = 99

vim.filetype.add({
  filename = {
    ["Tiltfile"] = "tiltfile",
    ["dot-zshrc"] = "zsh",
    ["dot-zprofile"] = "zsh",
    ["dot-zshenv"] = "zsh",
  },
  pattern = {
    ["Tiltfile.*"] = "tiltfile",
  },
})
