vim.cmd("let g:netrw_liststyle = 3")
vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

local opt = vim.opt

-- lines
opt.number = true
opt.relativenumber = true
opt.cursorline = true

-- tabs & indentation
opt.shiftwidth = 2
opt.expandtab = true
opt.tabstop = 2
opt.autoindent = true
opt.smartindent = true
opt.shiftround = true

-- UI
opt.foldlevel = 99
opt.showmode = false
opt.signcolumn = "yes"
opt.virtualedit = "block"
opt.wrap = false
opt.conceallevel = 2
opt.termguicolors = true
opt.scrolloff = 4
opt.sidescrolloff = 8

-- search settings
opt.ignorecase = true
opt.smartcase = true

-- backspace
opt.backspace = "indent,eol,start"

-- split windows
opt.splitright = true
opt.splitbelow = true

-- turn off swapfile
opt.swapfile = false

-- Auto save
opt.autowrite = true

-- Buffers
opt.confirm = true
opt.undofile = true
opt.undolevels = 10000

-- Autocompletion
opt.completeopt = "menu,menuone,noselect"
