local autocmd = vim.api.nvim_create_autocmd

local group = vim.api.nvim_create_augroup("LSP", { clear = true })


autocmd("BufEnter", {
    group = group,
    pattern = { "*.rs", "*.cpp" },
    callback = function()
        vim.g.completion_trigger_character = { '.', '::', '=' }
    end
})

autocmd("BufEnter", {
    group = group,
    callback = function() vim.g.completion_trigger_character = { '.', '=' } end
})
