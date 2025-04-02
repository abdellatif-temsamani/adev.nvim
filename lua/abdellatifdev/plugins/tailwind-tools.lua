-- tailwind-tools.lua
return {
    "luckasRanarison/tailwind-tools.nvim",
    event = require("abdellatifdev.consts").events.file,
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim", -- optional
        "neovim/nvim-lspconfig",         -- optional
    },
    opts = {
        conceal = {
            enabled = true, -- can be toggled by commands
            min_length = nil, -- only conceal classes exceeding the provided length
            symbol = "󱏿", -- only a single character is allowed
            highlight = { -- extmark highlight options, see :h 'highlight'
                fg = "#38BDF8",
            },
        },
    } -- your configuration
}
