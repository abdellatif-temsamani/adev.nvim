-- tailwind-tools.lua
return {
    "luckasRanarison/tailwind-tools.nvim",
    event = require("abdellatifdev.consts").events.lsp,
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim", -- optional
        "neovim/nvim-lspconfig",         -- optional
    },
    opts = {
        document_color = {
            enabled = false, -- can be toggled by commands
        },
        cmp = {
            highlight = "foreground", -- color preview style, "foreground" | "background"
        },
        conceal = {
            enabled = true, -- can be toggled by commands
            min_length = nil, -- only conceal classes exceeding the provided length
            symbol = "󱏿", -- only a single character is allowed
            highlight = { -- extmark highlight options, see :h 'highlight'

                fg = "#38BDF8",
            },
        },
    }
}
