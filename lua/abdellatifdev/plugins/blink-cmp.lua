return {
    {
        'saghen/blink.compat',
        version = '*',
        lazy = true,
        opts = {},
    },
    {
        'saghen/blink.cmp',
        version = '*',
        dependencies = {
            'rafamadriz/friendly-snippets',
            'honza/vim-snippets',
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
                    -- 'laravel',
                    'cmdline',
                    'omni',
                },
                providers = {
                    -- laravel = {
                    --     name = "laravel",
                    --     module = "blink.compat.source",
                    -- },
                }
            },

            snippets = { preset = 'luasnip' },
            signature = { enabled = true },
        }
    }
}
