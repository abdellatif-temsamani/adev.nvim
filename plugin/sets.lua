-- Modern Neovim options using vim.opt
local opt = vim.opt

-- Basics
vim.cmd "syntax on" -- enable syntax highlighting
opt.title = true
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.hlsearch = false
opt.smartcase = true
opt.concealcursor = "vin"
opt.linebreak = true

-- Window behavior
opt.splitbelow = true
opt.splitright = true

-- Indentation
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.expandtab = true
opt.smartindent = true

-- File handling
opt.writebackup = false
opt.undofile = true
opt.swapfile = false
opt.undodir = vim.fn.stdpath "state" .. "/undo"

-- Folding
opt.foldmethod = "marker"

-- Text formatting
opt.textwidth = 100
opt.wrap = false

-- Disable mouse
vim.cmd "set mouse="
