-- Create (or clear) the GENERAL augroup
local autocmd     = vim.api.nvim_create_autocmd
local general_grp = vim.api.nvim_create_augroup("GENERAL", { clear = true })

-- Trim trailing whitespace on save{{{
autocmd("BufWritePre", {
    group    = general_grp,
    pattern  = "*",
    callback = function()
        vim.cmd([[%s/\s\+$//e]])
    end,
}) -- }}}

-- Enable spell checking, 2‑space tabs, and expandtab for certain filetypes{{{
autocmd("FileType", {
    group   = general_grp,
    pattern = { "gitcommit", "markdown", "svelte", "cpp", "c", "dart" },
    command = "setlocal spell spelllang=en_gb,fr tabstop=2 shiftwidth=2 expandtab",
}) -- }}}

-- Disable automatic comment insertion on Enter for all filetypes{{{
autocmd("FileType", {
    group   = general_grp,
    pattern = "*",
    command = "setlocal formatoptions-=r formatoptions-=c formatoptions-=o",
}) -- }}}

-- Briefly highlight yanked text{{{
autocmd("TextYankPost", {
    group    = general_grp,
    callback = function()
        vim.highlight.on_yank({ timeout = 60 })
    end,
}) -- }}}
