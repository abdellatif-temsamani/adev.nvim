return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
        "nvim-mini/mini.icons",
        "nvim-lua/popup.nvim",
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
    },
    keys = {
        {
            "<leader>ff",
            function()
                require("telescope.builtin").find_files()
            end,
            desc = "find files",
        },
        {
            "<leader>fg",
            function()
                require("telescope.builtin").live_grep()
            end,
            desc = "grep files",
        },
        {
            "<leader>fc",
            function()
                require("telescope.builtin").find_files {
                    cwd = vim.fn.expand "%:p:h",
                    hidden = true,
                    prompt_title = "search files in current buffer dir",
                }
            end,
            desc = "colorscheme",
        },
        {
            "<leader>fb",
            function()
                require("telescope.builtin").buffers()
            end,
            desc = "find buffers",
        },
        {
            "<leader>fh",
            function()
                require("telescope.builtin").help_tags()
            end,
            desc = "help tags",
        },
        {
            "<leader>fm",
            function()
                require("telescope.builtin").man_pages()
            end,
            desc = "man pages",
        },
        {
            "<leader>fs",
            function()
                require("telescope.builtin").commands()
            end,
            desc = "commands",
        },
    },

    opts = {
        pickers = {
            find_files = {
                hidden = true,
            },
        },
        extensions = {
            fzf = {},
            noice = {},
        },
        defaults = {
            layout_strategy = "horizontal",
            layout_config = {
                horizontal = {
                    prompt_position = "bottom",
                    height = 0.99,
                    width = 0.99,
                    preview_width = 0.55,
                },
            },
            prompt_prefix = " ",
            color_devicons = true,
            selection_strategy = "closest",
            file_ignore_patterns = require("adev-common.utils").ignored_files,
            mappings = {
                i = {
                    ["<C-x>"] = false,
                    ["<C-h>"] = "which_key",
                },
            },
            border = {
                prompt = { 1, 1, 1, 1 },
                results = { 1, 1, 1, 1 },
                preview = { 1, 1, 1, 1 },
            },
            borderchars = {
                prompt = { " ", " ", "─", "│", "│", " ", "─", "└" },
                results = { "─", " ", " ", "│", "┌", "─", " ", "│" },
                preview = { "─", "│", "─", "│", "┬", "┐", "┘", "┴" },
            },
        },
    },
}
