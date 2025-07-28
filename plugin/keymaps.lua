local keymap_set = vim.keymap.set

keymap_set('n', '<leader>u', '<cmd>m .+1<cr>==', { noremap = true, silent = true, desc = "move 1 line down" })
keymap_set('n', '<leader>i', '<cmd>m .-2<cr>==', { noremap = true, silent = true, desc = "move 1 line up" })
keymap_set('n', '<leader>Q', '<cmd>quitall<CR>', { noremap = true, silent = true, desc = "quit nvim" })
keymap_set({ 'n', 'v' }, '\\', "\"+", { noremap = true, silent = true, desc = "unamed register" })
keymap_set('n', 'j', 'gj', { noremap = true, silent = true, desc = "great j" })
keymap_set('n', 'k', 'gk', { noremap = true, silent = true, desc = "great k" })

keymap_set('n', '<Leader>bs', '<cmd>write<CR>', { noremap = true, silent = true, desc = "save" })
keymap_set('n', '<leader>bq', function() require('mini.bufremove').wipeout() end,
    { noremap = true, silent = true, desc = "close buffer" })
keymap_set('n', '<leader>bp', '<cmd>bprevious<CR>', { noremap = true, silent = true, desc = "prev buffer" })
keymap_set('n', '<leader>bn', '<cmd>bnext<CR>', { noremap = true, silent = true, desc = "next buffer" })

keymap_set('n', '<leader>wq', '<cmd>close<CR>', { noremap = true, silent = true, desc = "close window" })
keymap_set('n', '<leader>wd', '<cmd>bwipeout<CR>', { noremap = true, silent = true, desc = "close window" })
keymap_set('n', '<leader>wv', '<cmd>vsplit<CR>', { noremap = true, silent = true, desc = "vertical split" })
keymap_set('n', '<leader>wh', '<cmd>split<CR>', { noremap = true, silent = true, desc = "horizontal split" })
keymap_set('n', '<leader>wp', '<cmd>tabprevious<cr>', { noremap = true, silent = true, desc = "prev tab" })
keymap_set('n', '<leader>wn', '<cmd>tabnext<cr>', { noremap = true, silent = true, desc = "next tab" })
keymap_set('n', '<leader>wo', '<cmd>tabnew<cr>', { noremap = true, silent = true, desc = "new tab" })

keymap_set('n', '<leader>qq', '<cmd>cclose<CR>', { noremap = true, silent = true, desc = "close quickfix" })
keymap_set('n', '<leader>qo', '<cmd>copen<CR>', { noremap = true, silent = true, desc = "open quickfix" })
keymap_set('n', '<leader>qp', '<cmd>cprevious<cr>', { noremap = true, silent = true, desc = "prev quickfix" })
keymap_set('n', '<leader>qn', '<cmd>cnext<cr>', { noremap = true, silent = true, desc = "next quickfix" })

keymap_set('n', '<c-k>', '<C-w>k', { noremap = true, silent = true, desc = "to go up split" })
keymap_set('n', '<c-j>', '<C-w>j', { noremap = true, silent = true, desc = "to go down split" })
keymap_set('n', '<c-l>', '<C-w>l', { noremap = true, silent = true, desc = "to go left split" })
keymap_set('n', '<c-h>', '<C-w>h', { noremap = true, silent = true, desc = "to go right split" })
keymap_set('n', '<m-k>', '<CMD>resize +2<CR>', { silent = true, desc = "resize split to up" })
keymap_set('n', '<m-j>', '<CMD>resize -2<CR>', { silent = true, desc = "resize split to down" })
keymap_set('n', '<m-l>', '<CMD>vertical resize -2<CR>', { silent = true, desc = "resize split to left" })
keymap_set('n', '<m-h>', '<CMD>vertical resize +2<CR>', { silent = true, desc = "resize split to right" })

keymap_set({ 'v', 'n' }, '<leader>cc', ":'<,'>fold<CR>", { noremap = true, silent = true, desc = "create fold" })
keymap_set('n', '<leader>co', '<cmd>foldopen<CR>', { noremap = true, silent = true, desc = "open fold" })
keymap_set('n', '<leader>cq', '<cmd>foldclose<CR>', { noremap = true, silent = true, desc = "close fold" })

keymap_set('t', '<c-t>', '<C-\\><C-n>', { noremap = true, silent = true })
keymap_set('n', '<leader>to', function() Snacks.lazygit() end, { noremap = true, silent = true, desc = "lazygit" })
keymap_set('n', '<leader>tq', function()
        local defaults = {
            win = { style = "terminal" },
        }

        local opts = Snacks.config.get("lazygit", defaults)
        Snacks.terminal({ "gh-dash" }, opts)
    end,
    { noremap = true, silent = true, desc = "gh-dash" })

keymap_set('n', '<leader>ml', '<cmd>Lazy<CR>', { noremap = true, silent = true, desc = "Lazy Nvim" })
keymap_set('n', '<leader>mm', '<cmd>Mason<CR>', { noremap = true, silent = true, desc = "Mason Nvim" })
