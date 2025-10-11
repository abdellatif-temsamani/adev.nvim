local events = require "adev.utils.consts.events"

return {
    "folke/lazydev.nvim",
    event = { events.buffer.new_file, events.lsp.attach, events.buffer.file_pre, },
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
