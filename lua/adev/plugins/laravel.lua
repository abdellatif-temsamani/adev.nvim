---@diagnostic disable: undefined-global
return {
    "adalessa/laravel.nvim",
    lazy = false,
    cond = function()
        return vim.fn.filereadable "artisan" ~= 0
    end,
    dependencies = {
        "neovim/nvim-lspconfig",
        "tpope/vim-dotenv",
        "nvim-telescope/telescope.nvim",
        "MunifTanjim/nui.nvim",
        "kevinhwang91/promise-async",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/nvim-nio",
    },
    keys = {
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
    },
}
