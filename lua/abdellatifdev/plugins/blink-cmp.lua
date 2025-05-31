return {
    'saghen/blink.cmp',
    -- build = "cargo build --release",
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
                indow = {
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
            default = { 'lsp', 'path', 'snippets', 'buffer', },
        },

        snippets = { preset = 'luasnip' },

        per_filetype = {
            lua = { inherit_defaults = true, 'lazydev' },
        },
        providers = {
            lazydev = {
                name = "LazyDev",
                module = "lazydev.integrations.blink",
                score_offset = 100,
            },
        },
    },
    signature = { enabled = true },
    opts_extend = { "sources.default" },
}
