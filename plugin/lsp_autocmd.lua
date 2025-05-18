local autocmd = vim.api.nvim_create_autocmd
local autogroup = vim.api.nvim_create_augroup

local group = autogroup("LSP", { clear = true })


autocmd("BufEnter", {
    group = group,
    pattern = { "*.rs", "*.cpp" },
    callback = function()
        vim.g.completion_trigger_character = { '.', '::', '=' }
    end
})

vim.cmd [[ autocmd BufRead,BufNewFile *.slint set filetype=slint ]]

autocmd("BufEnter", {
    group = group,
    callback = function() vim.g.completion_trigger_character = { '.', '=' } end
})

autocmd("LspAttach", {
    group = group,
    callback = function()
        local keymap_set = vim.keymap.set

        keymap_set({ 'n', 'v' }, '<leader>gl', function() vim.lsp.buf.format() end,
            { desc = "lint buffer", noremap = true, silent = true })
        keymap_set('n', '<leader>gd', function() vim.lsp.buf.definition() end,
            { desc = "go to definition", noremap = true, silent = true })
        keymap_set('n', '<leader>gD', function() vim.lsp.buf.declaration() end,
            { desc = "go to declaration", noremap = true, silent = true })
        keymap_set('n', '<leader>gh', function() vim.lsp.buf.hover() end,
            { desc = "lsp hover", noremap = true, silent = true })
        keymap_set('n', '<leader>gi', function() vim.lsp.buf.implementation() end,
            { desc = "lsp implementation", noremap = true, silent = true })
        keymap_set('n', '<leader>gr', function() vim.lsp.buf.rename() end,
            { desc = "lsp rename", noremap = true, silent = true })
        keymap_set('n', '<leader>gt', function() vim.lsp.buf.type_definition() end,
            { desc = "lsp type definition", noremap = true, silent = true })
        keymap_set({ 'n', 'v' }, '<leader>gc', function() vim.lsp.buf.code_action() end,
            { desc = "lsp code action", noremap = true, silent = true })
        keymap_set('n', '<leader>gs', function() vim.lsp.buf.signature_help() end,
            { desc = "lsp signature help", noremap = true, silent = true })
        keymap_set('n', '<leader>go', function() vim.diagnostic.open_float() end,
            { desc = "line diagnostic", noremap = true, silent = true })
        keymap_set('n', '<leader>gp', function() vim.diagnostic.jump({ count = -1, float = true }) end,
            { desc = "previous diagnostic", noremap = true, silent = true })
        keymap_set('n', '<leader>gn', function() vim.diagnostic.jump({ count = 1, float = true }) end,
            { desc = "next diagnostic", noremap = true, silent = true })
        keymap_set('n', '<leader>gr', function() vim.lsp.buf.references() end,
            { desc = "lsp reference", noremap = true, silent = true })
    end
})
