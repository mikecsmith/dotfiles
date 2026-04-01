-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

require("config.autocmds.lsp")
require("config.autocmds.filetypes")
require("config.autocmds.editor")
