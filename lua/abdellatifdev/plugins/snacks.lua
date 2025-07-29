return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        { "<leader>n",  function() Snacks.explorer() end, desc = "Files" },
        { "<leader>wa", function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
    },
    opts = {
        explorer     = {
            enabled = true,
            replace_netrw = true,
        },
        picker       = {
            sources = {
                explorer = {
                }
            }
        },
        input        = { enabled = true },
        lazygit      = { enabled = true },
        statuscolumn = {
            enabled = true,
            left = { "mark", "sign" },
            right = { "fold", "git" },
            folds = {
                open = false,
                git_hl = false,
            },
            git = {
                patterns = { "GitSign", "MiniDiffSign" },
            },
            refresh = 50, -- refresh at most every 50ms
        },
    },
}
