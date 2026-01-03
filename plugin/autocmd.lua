local events = require "adev-common.utils.events"
local autocmd = vim.api.nvim_create_autocmd
local general_grp = vim.api.nvim_create_augroup("GENERAL", { clear = true })
local onbarding_group = vim.api.nvim_create_augroup("ONBOARDING", { clear = true })
local onboarding = require "adev.onboarding"

autocmd(events.vim.startup, {
    group = onbarding_group,
    callback = function()
        onboarding:onboarding()
    end,
})

autocmd(events.file.type, {
    group = general_grp,
    pattern = "gdscript",
    callback = function()
        vim.opt_local.expandtab = true -- use spaces
        vim.opt_local.shiftwidth = 4
        vim.opt_local.tabstop = 4
    end,
})

autocmd(events.file.type, {
    group = general_grp,
    pattern = { "c", "cpp" },
    callback = function()
        vim.opt_local.expandtab = true -- use spaces
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

autocmd(events.buffer.write_pre, {
    group = general_grp,
    pattern = "*",
    callback = function()
        vim.cmd [[%s/\s\+$//e]]
    end,
})

autocmd(events.text.yank_post, {
    group = general_grp,
    callback = function()
        vim.highlight.on_yank { timeout = 60 }
    end,
})

autocmd(events.file.type, {
    group = general_grp,
    pattern = "*",
    command = "setlocal formatoptions-=r formatoptions-=c formatoptions-=o",
})
autocmd("BufWritePost", {
    group = onbarding_group,
    pattern = onboarding.init_opts,
    callback = function()
        onboarding.restart_neovim()
    end,
})
