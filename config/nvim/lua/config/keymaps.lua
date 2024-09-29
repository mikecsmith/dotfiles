-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

local wezterm = require("fathom.wezterm")

-- stylua: ignore start
map("n", "<M-h>", function() wezterm.move_or_fallback("h") end, { noremap = true, silent = true })
map("n", "<M-j>", function() wezterm.move_or_fallback("j") end, { noremap = true, silent = true })
map("n", "<M-k>", function() wezterm.move_or_fallback("k") end, { noremap = true, silent = true })
map("n", "<M-l>", function() wezterm.move_or_fallback("l") end, { noremap = true, silent = true })
-- stylua: ignore end
