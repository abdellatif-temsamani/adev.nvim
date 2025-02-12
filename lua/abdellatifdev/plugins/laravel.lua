return {
    {
        "adalessa/laravel.nvim",
        cond = function()
            return vim.fn.filereadable("artisan") ~= 0
        end,
        dependencies = {
            "tpope/vim-dotenv",
            "nvim-telescope/telescope.nvim",
            "MunifTanjim/nui.nvim",
            "kevinhwang91/promise-async",
        },
        ft = { "blade", "php" },
        keys = {
            { "<leader>la", ":Laravel artisan<cr>", desc = "artisan commands" },
            { "<leader>lr", ":Laravel routes<cr>",  desc = "routes" },
            { "<leader>lm", ":Laravel related<cr>", desc = "related" },
        },
        opts = {},
        config = true,
    },
    {
        "Bleksak/laravel-ide-helper.nvim",
        ft = { "blade", "php" },
        opts = {
            write_to_models = true,
            save_before_write = true,
            format_after_gen = true,
        },
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
