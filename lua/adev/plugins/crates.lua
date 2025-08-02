return {
    "Saecki/crates.nvim",
    event = { "BufEnter Cargo.toml" },
    cond = function()
        return vim.fn.filereadable("Cargo.toml") ~= 0
    end,
    opts = {},
}
