return {
    "folke/lazydev.nvim",
    event = require "adev.consts".events:merge({ "lsp", "file" }),
    cond = function()
        return vim.fn.filereadable("init.lua") ~= 0 or
            vim.fn.isdirectory("lua") ~= 0
    end,
    opts = {
        library = {
            { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
    },
    dependencies = {
        { "Bilal2453/luvit-meta", lazy = true },
    }
}
