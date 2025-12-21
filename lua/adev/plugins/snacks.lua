return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        {
            "<leader>bq",
            function()
                Snacks.bufdelete()
            end,
            desc = "close buffer",
        },
        {
            "<leader>n",
            function()
                Snacks.explorer()
            end,
            desc = "Files",
        },
        {
            "<leader>wa",
            function()
                Snacks.zen.zoom()
            end,
            desc = "Toggle Zoom",
        },
        {
            "<leader>to",
            function()
                Snacks.lazygit {
                    win = {
                        style = "terminal",
                        border = Adev.ui.border,
                    },
                }
            end,
            desc = "lazygit",
        },
        {
            "<leader>N",
            desc = "Neovim News",
            function()
                Snacks.win {
                    file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
                    border = Adev.ui.border,
                    width = 0.9,
                    height = 0.9,
                    wo = {
                        spell = false,
                        wrap = false,
                        signcolumn = "yes",
                        statuscolumn = " ",
                        conceallevel = 3,
                    },
                }
            end,
        },
    },
    opts = {
        explorer = {
            enabled = true,
            replace_netrw = true,
        },
        picker = {
            sources = {
                explorer = {},
            },
        },
        input = { enabled = true },
        lazygit = { enabled = true },
        notifier = {
            enabled = true,
            style = "compact",
            timeout = 4000,
            width = { min = 30, max = 0.3 },
            height = { min = 1, max = 0.4 },
            margin = { top = 0, right = 0, bottom = 0 },
            padding = false,
            sort = { "level", "added" },
            top_down = true,
            date_format = "%H:%M",
            more_format = "… %d",
            refresh = 100,
        },
        image = { enabled = true },
        statuscolumn = {
            enabled = true,
            left = { "mark", "sign" },
            right = { "fold", "git" },
            folds = {
                open = false,
                git_hl = false,
            },
            git = {
                patterns = { "GitSign" },
            },
            refresh = 50, -- refresh at most every 50ms
        },
    },
}
