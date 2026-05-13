local plugin = require "adev-common.plugin"

return {
    "folke/lazydev.nvim",
    event = plugin.file_events(),
    cond = function()
        return vim.fn.filereadable "init.lua" ~= 0 or vim.fn.isdirectory "lua" ~= 0
    end,
    opts = {
        library = {
            { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
    },
    dependencies = {
        { "Bilal2453/luvit-meta", lazy = true },
    },
}
