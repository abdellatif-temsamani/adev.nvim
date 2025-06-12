return {
    {
        "vuki656/package-info.nvim",
        event = { "BufEnter package.json" },
        dependencies = { "MunifTanjim/nui.nvim", },
        cond = function()
            return vim.fn.filereadable("package.json") ~= 0
        end,
        opts = {},
    }
}
