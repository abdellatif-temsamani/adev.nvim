return {
    "folke/lazydev.nvim",
    cond = function()
        return vim.fn.filereadable("lua") ~= 0 or vim.fn.isdirectory("lua") ~= 0
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
