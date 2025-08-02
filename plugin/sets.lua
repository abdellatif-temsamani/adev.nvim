local o = vim.o

o.syntax = "true"
o.foldmethod = "marker"
o.splitbelow = true
o.splitright = true
o.hlsearch = false
o.history = 100
o.scrolloff = 8

o.writebackup = false
o.undofile = true
o.swapfile = false
o.undodir = vim.fn.stdpath("state") .. "/undo"

o.textwidth = 100
o.wrap = false
o.shiftwidth = 4
o.softtabstop = 4
o.tabstop = 4
o.expandtab = true
o.smartindent = true
o.title = true
o.number = true
o.relativenumber = true

o.smartcase = true
o.concealcursor = "vin"
o.linebreak = true

vim.cmd [[ set mouse= ]]
vim.cmd [[ set nowrap ]]
