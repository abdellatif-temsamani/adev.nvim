return {
    "echasnovski/mini.nvim",
    version = "*",
    event = require("adev.utils.events").vim.lazy,
    config = function()
        require "adev.config.mini"
    end,
}
