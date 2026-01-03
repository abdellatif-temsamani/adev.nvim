---@diagnostic disable: undefined-global
return {
    "adalessa/laravel.nvim",
    event = require("adev-common.utils.events").vim.lazy,
    cond = function()
        return vim.fn.filereadable "artisan" ~= 0
    end,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "neovim/nvim-lspconfig",
        "nvim-telescope/telescope.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/nvim-nio",
        "saghen/blink.cmp",
        "saghen/blink.compat",
    },
    keys = {
        {
            "gf",
            function()
                local ok, res = pcall(function()
                    if Laravel.app("gf").cursorOnResource() then
                        return "<cmd>lua Laravel.commands.run('gf')<cr>"
                    end
                end)
                if not ok or not res then
                    return "gf"
                end
                return res
            end,
            expr = true,
            noremap = true,
        },
        {
            "<leader>ll",
            function()
                Laravel.pickers.laravel()
            end,
            desc = "Laravel nvim commands",
        },
        {
            "<leader>la",
            function()
                Laravel.pickers.artisan()
            end,
            desc = "Artisan Picker",
        },
        {
            "<leader>lt",
            function()
                Laravel.commands.run "actions"
            end,
            desc = "Actions Picker",
        },
        {
            "<leader>lr",
            function()
                Laravel.pickers.routes()
            end,
            desc = "Routes Picker",
        },
        {
            "<leader>lh",
            function()
                Laravel.run "artisan docs"
            end,
            desc = "Documentation",
        },
        {
            "<leader>lm",
            function()
                Laravel.pickers.make()
            end,
            desc = "Make Picker",
        },
        {
            "<leader>lc",
            function()
                Laravel.pickers.commands()
            end,
            desc = "Commands Picker",
        },
        {
            "<leader>lo",
            function()
                Laravel.pickers.resources()
            end,
            desc = "Resources Picker",
        },
        {
            "<leader>lp",
            function()
                Laravel.commands.run "command_center"
            end,
            desc = "Command Center",
        },
    },
    opts = {
        lsp_server = "intelephense",
        features = {
            pickers = {
                --- @type "snacks" | "telescope" | "fzf-lua" | "ui-select"
                provider = "telescope",
            },
        },
    },
    config = function(_, opts)
        require("laravel").setup(opts)

        local blink = require "blink.cmp"

        blink.add_source_provider("laravel", {
            name = "laravel",
            module = "blink.compat.source",
            score_offset = 95,
            opts = {},
        })

        blink.add_filetype_source("php", "laravel")
    end,
}
