return {
    {
        'saghen/blink.compat',
        after = 'saghen/blink.cmp',
        version = "2.*",
        opts = {},
    },
    {
        'saghen/blink.cmp',
        event = require("adev.consts").events.insert,
        version = "v1.3.1",
        dependencies = {
            'saghen/blink.compat',
            'rafamadriz/friendly-snippets',
            'neovim/nvim-lspconfig',
            'honza/vim-snippets',
            'disrupted/blink-cmp-conventional-commits',
        },
        opts = {
            cmdline = {
                keymap = { preset = 'inherit' },
                completion = { menu = { auto_show = true } },
            },

            keymap = {
                preset = 'default',
                ["<C-k>"] = { "scroll_documentation_up", "fallback" },
                ["<C-j>"] = { "scroll_documentation_down", "fallback" },
            },

            completion = {
                list = { selection = { preselect = true, auto_insert = true } },
                accept = { auto_brackets = { enabled = false } },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    window = {
                        border = 'single'
                    }
                },
                menu = {
                    border = 'single',
                    draw = {
                        columns = { { "kind_icon", gap = 1, "label" } },
                    }
                },
            },

            sources = {
                default = {
                    'lsp',
                    'path',
                    'snippets',
                    'buffer',
                    'laravel',
                    'cmdline',
                    'omni',
                },

                per_filetype = {
                    gitcommit = { 'conventional_commits', 'path', 'buffer' }
                },

                providers = {
                    laravel = {
                        name = "laravel",
                        module = "blink.compat.source",
                        should_show_items = function()
                            return vim.tbl_contains({
                                "php",
                                "blade",
                                "javascript",
                                "javascriptreact",
                                "typescript",
                                "typescriptreact"
                            }, vim.o.filetype)
                        end
                    },
                    conventional_commits = {
                        name = 'Conventional Commits',
                        module = 'blink-cmp-conventional-commits',
                        enabled = function()
                            return vim.bo.filetype == 'gitcommit'
                        end,
                        opts = {}, -- none so far
                    },
                }
            },

            snippets = { preset = 'luasnip' },
            signature = { enabled = true },
            fuzzy = { implementation = "prefer_rust_with_warning" },

        }
    }
}
