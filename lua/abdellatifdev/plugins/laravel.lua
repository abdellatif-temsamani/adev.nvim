return {
    {
        "adalessa/laravel.nvim",
        dependencies = {
            "tpope/vim-dotenv",
            "nvim-telescope/telescope.nvim",
            "MunifTanjim/nui.nvim",
            "kevinhwang91/promise-async",
        },
        cmd = { "Laravel" },
        keys = {
            { "<leader>la", ":Laravel artisan<cr>" },
            { "<leader>lr", ":Laravel routes<cr>" },
            { "<leader>lm", ":Laravel related<cr>" },
        },
        opts = {},
        config = true,
    },
    {
        "Bleksak/laravel-ide-helper.nvim",
        event = require("abdellatifdev.consts").events.file,
        opts = {
            write_to_models = true,
            save_before_write = true,
            format_after_gen = true,
        },
        enabled = function()
            return vim.fn.filereadable("artisan") ~= 0
        end,
        keys = {
            {
                "<leader>lgm",
                function()
                    require("laravel-ide-helper").generate_models(vim.fn.expand("%"))
                end,
                desc = "Generate Model Info for current model"
            },
            {
                "<leader>lgM",
                function()
                    require("laravel-ide-helper").generate_models()
                end,
                desc = "Generate Model Info for all models"
            },
        }
    }
}
