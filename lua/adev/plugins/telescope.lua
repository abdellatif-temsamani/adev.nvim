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
        {
            "<leader>fc",
            function()
                require("telescope.builtin").colorscheme()
            end,
            desc = "colorscheme",
        },
        {
            "<leader>fa",
            function()
                require("telescope.builtin").treesitter()
            end,
            desc = "treesitter",
        },
    },

    opts = {
        pickers = {
            find_files = {
                hidden = true,
                find_command = {
                    "rg",
                    "--files",
                    "--hidden",
                    "--glob=!**/yarn.lock",
                    "--glob=!**/pnpm-lock.yaml",
                    "--glob=!**/node_modules/*",
                    "--glob=!**/.git/*",
                    "--glob=!**/Cargo.lock*",
                    "--glob=!**/.idea/*",
                    "--glob=!**/__pycache__/*",
                    "--glob=!**/.vscode/*",
                    "--glob=!**/build/*",
                    "--glob=!**/dist/*",
                    "--glob=!**/yarn.lock",
                    "--glob=!**/package-lock.json",
                },
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
            file_ignore_patterns = require("adev.utils").ignored_files,
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
