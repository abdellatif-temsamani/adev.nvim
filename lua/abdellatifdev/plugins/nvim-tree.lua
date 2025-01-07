local ignored_files = require("abdellatifdev.consts").ignored_files

return {
    {
        "kyazdani42/nvim-tree.lua",
        keys = {
            { "<leader>n", "<cmd>NvimTreeToggle<cr>", desc = "NvimTree" },
        },
        opts = {
            sort_by = "case_sensitive",
            view = { adaptive_size = false },
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
