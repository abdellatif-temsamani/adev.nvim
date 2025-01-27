return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        lazygit      = { enabled = true },
        bigfile      = { enabled = true },
        dashboard    = {
            enabled = true,
            sections = {
                {
                    section = "terminal",
                    indent = 10,
                    height= 5,
                    cmd = "toilet -f future 'Abdellatif Dev'",
                },
                { section = "startup" },
            },
        },
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
