return {
    {
        'saghen/blink.compat',
        version = '2.*',
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
            keymap = {
                preset = 'default',
                ["<C-k>"] = { "scroll_documentation_up", "fallback" },
                ["<C-j>"] = { "scroll_documentation_down", "fallback" },
            },

            completion = {
                list = { selection = { preselect = true, auto_insert = true } },
                accept = { auto_brackets = { enabled = false }, },
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
                        columns = { { "label", gap = 1, "kind_icon" } },
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
                    'omni'
                },
                per_filetype = {
                    lua = { inherit_defaults = true, 'lazydev' },
                },
                providers = {
                    laravel = {
                        name = "laravel",
                        module = "blink.compat.source",
                    },
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                },
            },

            snippets = { preset = 'luasnip' },
        },
        signature = { enabled = true },
        opts_extend = { "sources.default" },
    }
}
