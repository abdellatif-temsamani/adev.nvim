local autocmd = vim.api.nvim_create_autocmd
local autogroup = vim.api.nvim_create_augroup

local group_lsp = autogroup("LSP", { clear = true })
local group_lua = autogroup("LUA", { clear = true })
local group_gen = autogroup("GENERAL", { clear = true })

autocmd("BufWritePre",
    { group = group_gen, callback = function() vim.cmd("%s/\\s\\+$//e") end })

autocmd("FileType", {
    group = group_gen,
    pattern = { "gitcommit", "markdown", "svelte", "cpp", "c", "dart" },
    command = "setlocal spell spelllang=en_gb tabstop=2 shiftwidth=2 expandtab"
})

autocmd("FileType",
    { group = group_gen, pattern = { "tf" }, command = "set ft=terraform" })

autocmd("FileType", {
    group = group_gen,
    command = "set formatoptions-=r formatoptions-=c formatoptions-=o"
})

autocmd("BufEnter", {
    group = group_lsp,
    pattern = { "*.rs", "*.cpp" },
    callback = function()
        vim.g.completion_trigger_character = { '.', '::', '=' }
    end
})

vim.cmd [[ autocmd BufRead,BufNewFile *.slint set filetype=slint ]]

autocmd("BufEnter", {
    group = group_lsp,
    callback = function() vim.g.completion_trigger_character = { '.', '=' } end
})

autocmd("TextYankPost", {
    group = group_lua,
    callback = function() vim.highlight.on_yank({ timeout = 60 }) end
})
