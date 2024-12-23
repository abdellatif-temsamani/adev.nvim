return {
    'nvim-tree/nvim-tree.lua',
    keys = {
        { "<leader>n", "<cmd>NvimTreeToggle<cr>", desc = "Open Oil" },
    },
    opts = {
        filesystem_watchers = {
            enable = true,
            debounce_delay = 50,
            ignore_dirs = require("abdellatifdev.consts").ignored_files,
        },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
}
