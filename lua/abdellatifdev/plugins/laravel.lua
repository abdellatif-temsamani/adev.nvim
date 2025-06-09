return {
    {
        "adalessa/laravel.nvim",
        cond = function()
            return vim.fn.filereadable("artisan") ~= 0
        end,
        event = require("abdellatifdev.consts").events.file,
        dependencies = {
            "tpope/vim-dotenv",
            "nvim-telescope/telescope.nvim",
            "MunifTanjim/nui.nvim",
            "kevinhwang91/promise-async",
            "nvim-treesitter/nvim-treesitter",
        },
        keys = {
            { "<leader>la", ":Laravel artisan<cr>", desc = "artisan commands" },
            { "<leader>lr", ":Laravel routes<cr>",  desc = "artisan route:list" },
            { "<leader>lm", ":Laravel make<cr>", desc = "artisan make" },
        },
        opts = {},
    },
}
