return {
    "Saecki/crates.nvim",
    cond = function()
        return vim.fn.filereadable("Cargo.toml") ~= 0
    end,
    opts = {},
}
