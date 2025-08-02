local ignored_files = require("adev.consts").ignored_files

return {
    "nvim-telescope/telescope.nvim",
    module = false,
    dependencies = {
        { "nvim-lua/popup.nvim", },
        { "nvim-lua/plenary.nvim", },
    },
    keys = {
        { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "find files", },
        { "<leader>fg", function() require("telescope.builtin").live_grep() end,  desc = "grep files", },
        { "<leader>fb", function() require("telescope.builtin").buffers() end,    desc = "find buffers", },
        { "<leader>fh", function() require("telescope.builtin").help_tags() end,  desc = "help tags", },
        { "<leader>fm", function() require("telescope.builtin").man_pages() end,  desc = "man pages", },
        { "<leader>fs", function() require("telescope.builtin").commands() end,   desc = "commands", },
        { "<leader>fa", function() require("telescope.builtin").treesitter() end, desc = "treesitter", },
        { "<leader>ft", function() vim.cmd [[ TodoTelescope ]] end,               desc = "TodoTelescope", },
        { "<leader>fn", function() vim.cmd [[ NoiceTelescope ]] end,              desc = "NoiceTelescope", },
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
            fzf       = {},
            worktrees = {},
            noice     = {},
        },
        defaults = {
            layout_strategy = 'horizontal',
            layout_config = {
                horizontal = {
                    prompt_position = 'bottom',
                    height = .99,
                    width = .99,
                    preview_width = 0.60, -- Fraction of the layout width
                },
            },
            prompt_prefix = " ",
            color_devicons = true,
            selection_strategy = "closest",
            file_ignore_patterns = ignored_files,
            mappings = {
                i = {
                    ["<C-x>"] = false,
                    ["<C-h>"] = "which_key"
                }
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
            }
        }
    },

}
