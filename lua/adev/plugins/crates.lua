return {
    "Saecki/crates.nvim",
    event = require("adev.utils.consts.events").buffer._enter("Cargo.toml"),
    cond = function()
        return vim.fn.filereadable("Cargo.toml") ~= 0
    end,
    opts = {},
}
