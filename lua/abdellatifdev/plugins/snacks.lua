return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        { "<leader>n",  function() Snacks.explorer() end, desc = "Files" },
        { "<leader>wa", function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
        {
            "<leader>N",
            desc = "Neovim News",
            function()
                Snacks.win({
                    file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
                    border = "rounded",
                    width = 0.9,
                    height = 0.9,
                    wo = {
                        spell = false,
                        wrap = false,
                        signcolumn = "yes",
                        statuscolumn = " ",
                        conceallevel = 3,
                    },
                })
            end,
        }
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
