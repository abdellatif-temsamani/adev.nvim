return {
    {
        "adalessa/laravel.nvim",
        cond = function()
            return vim.fn.filereadable("artisan") ~= 0
        end,
        event = require("abdellatifdev.consts").events.file,
        after ={"nvim-treesitter/nvim-treesitter"},
        dependencies = {
            "tpope/vim-dotenv",
            "nvim-telescope/telescope.nvim",
            "MunifTanjim/nui.nvim",
            "kevinhwang91/promise-async",
        },
        keys = {
            { "<leader>la", ":Laravel artisan<cr>", desc = "artisan commands" },
            { "<leader>lr", ":Laravel routes<cr>",  desc = "routes" },
            { "<leader>lm", ":Laravel related<cr>", desc = "related" },
        },
        opts = {},
    },
    {
        "Bleksak/laravel-ide-helper.nvim",
        opts = {
            write_to_models = true,
            save_before_write = true,
            format_after_gen = true,
        },
        event = require("abdellatifdev.consts").events.file,
        cond = function()
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
                "<leader>lga",
                function()
                    require("laravel-ide-helper").generate_models()
                end,
                desc = "Generate Model Info for all models"
            },
        }
    }
}
