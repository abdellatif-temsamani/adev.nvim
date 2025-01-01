return {
    'saghen/blink.cmp',
    build = "cargo build --release",
    event = require("abdellatifdev.consts").events.file,
    dependencies = {
        'rafamadriz/friendly-snippets',
        'honza/vim-snippets',
        {
            'L3MON4D3/LuaSnip',
            event = require("abdellatifdev.consts").events.file,
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
            nerd_font_variant = 'mono'
        },

        sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },

        },
    },
    opts_extend = { "sources.default" }
}
