return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        input        = { enabled = true },
        lazygit      = { enabled = true },
        bufdelete    = { enabled = true },
        bigfile      = { enabled = true },
        notifier     = { enabled = true },
        scroll       = { enabled = true },
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
