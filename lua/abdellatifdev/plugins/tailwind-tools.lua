-- tailwind-tools.lua
return {
    "luckasRanarison/tailwind-tools.nvim",
    event = require("abdellatifdev.consts").events.file,
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-telescope/telescope.nvim", -- optional
        "neovim/nvim-lspconfig",     -- optional
    },
    opts = {}                        -- your configuration
}
