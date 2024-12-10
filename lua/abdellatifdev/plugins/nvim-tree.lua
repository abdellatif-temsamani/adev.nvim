local ignored_files = require("abdellatifdev.consts").ingored_files

return {
    {
        "kyazdani42/nvim-tree.lua",
        lazy = true,
        dependencies = {
            'stevearc/dressing.nvim',
        },
        keys = {
            { "<leader>n", function() vim.cmd [[ NvimTreeToggle ]] end, desc = "NvimTree" },
        },
        opts = {
            sort = {
                sorter = "case_sensitive",
            },
            view = {
                adaptive_size = false,
                width = 30,
            },
            update_cwd = false,
            diagnostics = {
                enable = true,
                icons = { hint = "", info = "", warning = "", error = "" }
            },
            update_focused_file = {
                enable = true,
                update_cwd = true,
                ignore_list = ignored_files
            },
            filters = { dotfiles = true, custom = ignored_files },
            git = { enable = true, ignore = true, timeout = 500 },
            trash = { cmd = "rm", require_confirm = false }
        }

    },
}
