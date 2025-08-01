local autocmd     = vim.api.nvim_create_autocmd
local general_grp = vim.api.nvim_create_augroup("GENERAL", { clear = true })

autocmd("BufWritePre", {
    group    = general_grp,
    pattern  = "*",
    callback = function()
        vim.cmd([[%s/\s\+$//e]])
    end,
})

autocmd("FileType", {
    group   = general_grp,
    pattern = "*",
    command = "setlocal formatoptions-=r formatoptions-=c formatoptions-=o",
})

autocmd("TextYankPost", {
    group    = general_grp,
    callback = function()
        vim.highlight.on_yank({ timeout = 60 })
    end,
})
