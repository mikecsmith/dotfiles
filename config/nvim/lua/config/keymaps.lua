-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Move Lines (Normal Mode)
map("n", "<D-A-j>", "<cmd>m .+1<cr>==回", { desc = "Move Line Down (Cmd+Alt)" })
map("n", "<D-A-k>", "<cmd>m .-2<cr>==", { desc = "Move Line Up (Cmd+Alt)" })

-- Move Lines (Visual Mode)
map("v", "<D-A-j>", ":m '>+1<CR>gv=gv", { desc = "Move Selection Down" })
map("v", "<D-A-k>", ":m '<-2<CR>gv=gv", { desc = "Move Selection Up" })
