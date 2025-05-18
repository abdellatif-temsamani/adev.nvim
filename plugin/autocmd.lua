local autocmd = vim.api.nvim_create_autocmd
local autogroup = vim.api.nvim_create_augroup

local group = autogroup("GENERAL", { clear = true })

autocmd("BufWritePre",
    { group = group, callback = function() vim.cmd("%s/\\s\\+$//e") end })

autocmd("FileType", {
    group = group,
    pattern = { "gitcommit", "markdown", "svelte", "cpp", "c", "dart" },
    command = "setlocal spell spelllang=en_gb,fr tabstop=2 shiftwidth=2 expandtab"
})

autocmd("FileType",
    { group = group, pattern = { "tf" }, command = "set ft=terraform" })

autocmd("FileType", {
    group = group,
    command = "set formatoptions-=r formatoptions-=c formatoptions-=o"
})

autocmd("TextYankPost", {
    group = group,
    callback = function() vim.highlight.on_yank({ timeout = 60 }) end
})
