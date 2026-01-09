return {
    {
        "saghen/blink.compat",
        after = "saghen/blink.cmp",
        version = "2.*",
        opts = {},
    },
    {
        "saghen/blink.cmp",
        -- optional: provides snippets for the snippet source
        dependencies = {
            "joelazar/blink-calc",
            "L3MON4D3/LuaSnip",
        },
        event = require("adev-common.utils.events").insert.enter,
        version = "1.*",
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            cmdline = {
                enabled = true,
                keymap = { preset = "cmdline" },
                completion = { ghost_text = { enabled = true }, menu = { auto_show = true } },
            },

            keymap = {
                preset = "default",
                ["<C-k>"] = { "scroll_documentation_up", "fallback" },
                ["<C-j>"] = { "scroll_documentation_down", "fallback" },
            },

            appearance = {
                nerd_font_variant = "mono",
            },

            completion = {
                list = { selection = { preselect = true, auto_insert = true } },
                accept = { auto_brackets = { enabled = false } },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    window = { border = nil },
                },
                menu = {
                    border = nil,
                    draw = {
                        columns = { { "kind_icon", gap = 1, "label", "kind" } },
                    },
                },
            },

            sources = {
                default = { "lsp", "path", "snippets", "buffer", "calc" },
                providers = {
                    calc = {
                        name = "Calc",
                        module = "blink-calc",
                    },
                },
            },

            snippets = { preset = "luasnip" },

            fuzzy = {
                implementation = "rust",
                sorts = {
                    "exact",
                    -- defaults
                    "score",
                    "sort_text",
                },
            },
        },
        opts_extend = { "sources.default" },
    },
}
