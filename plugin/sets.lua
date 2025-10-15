-- Modern Neovim options using vim.opt
local o, opt = vim.o, vim.opt

-- Basics
o.confirm = true
opt.diffopt = {
    "filler",
    "indent-heuristic",
    "linematch:60",
    "vertical",
}
o.emoji = true
opt.title = true
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.hlsearch = false
opt.smartcase = true
o.nrformats = "alpha"

-- Cursor
o.cursorline = true
opt.concealcursor = "vin"
opt.cursorlineopt = { "number" }
opt.linebreak = true
opt.guicursor = {
    "n-sm:block",
    "v:hor50",
    "c-ci-cr-i-ve:ver10",
    "o-r:hor10",
    "a:Cursor/Cursor-blinkwait1-blinkon1-blinkoff1",
}

-- Window behavior
opt.splitbelow = true
opt.splitright = true
o.equalalways = false
o.inccommand = "split"
o.splitkeep = "screen"
o.winborder = "none"

-- Indentation
opt.shiftwidth = 4
opt.softtabstop = 4
opt.tabstop = 4
opt.expandtab = true
opt.smartindent = true
o.breakindent = true
o.breakindentopt = "list:-1"

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

o.numberwidth = 3

-- Disable mouse
o.mouse = ""
