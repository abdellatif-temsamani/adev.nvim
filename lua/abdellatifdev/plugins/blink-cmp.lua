return {
    'saghen/blink.cmp',
    build = "cargo build --release",
    event = require("abdellatifdev.consts").insert_event,
    dependencies = {
        'rafamadriz/friendly-snippets',
        'honza/vim-snippets',
        {
            'L3MON4D3/LuaSnip',
            event = require("abdellatifdev.consts").insert_event,
            build = "make install_jsregexp",
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
                require("luasnip.loaders.from_snipmate").lazy_load()
            end,
        }
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = 'default',
            ["<C-k>"] = { "scroll_documentation_up", "fallback" },
            ["<C-j>"] = { "scroll_documentation_down", "fallback" },
        },

        completion = {
            accept = { auto_brackets = { enabled = false }, },
            documentation = { auto_show = true, auto_show_delay_ms = 500 },

        },

        appearance = {
            use_nvim_cmp_as_default = false,
            nerd_font_variant = 'mono'
        },

        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer', "lazydev" },
            providers = {
                path = {
                    name = "path",
                    enabled = true,
                    module = "blink.cmp.sources.path",
                    score_offset = 960, -- the higher the number, the higher the priority
                },
                lsp = {
                    name = "lsp",
                    enabled = true,
                    module = "blink.cmp.sources.lsp",
                    score_offset = 1000, -- the higher the number, the higher the priority
                },
                snippets = {
                    name = "snippets",
                    enabled = true,
                    module = "blink.cmp.sources.snippets",
                    score_offset = 990, -- the higher the number, the higher the priority
                },
                luasnip = {
                    name = "luasnip",
                    enabled = true,
                    module = "blink.cmp.sources.luasnip",
                    score_offset = 990, -- the higher the number, the higher the priority
                },
                buffer = {
                    name = "buffer",
                    enabled = true,
                    module = "blink.cmp.sources.buffer",
                    score_offset = 500, -- the higher the number, the higher the priority
                },
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    score_offset = 100,
                },
            }
        },
    },
    opts_extend = { "sources.default" }
}
