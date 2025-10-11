local events = require "adev.utils.consts.events"
return {
    {
        "saghen/blink.compat",
        after = "saghen/blink.cmp",
        version = "2.*",
        opts = {},
    },
    {
        "saghen/blink.cmp",
        event = {
            events.insert.enter,
            events.cmd.enter,
            events.lsp.attach,
        },
        -- BUG: any version above 1.3.1 don't work for some reason
        version = "v1.3.1",
        dependencies = {
            "saghen/blink.compat",
            "rafamadriz/friendly-snippets",
            "honza/vim-snippets",
            "L3MON4D3/LuaSnip",
            "disrupted/blink-cmp-conventional-commits",
        },
        ---@module "blink.cmp"
        ---@type blink.cmp.Config
        opts = {
            cmdline = {
                keymap = { preset = "inherit" },
                completion = { ghost_text = { enabled = true }, menu = { auto_show = true } },
            },

            keymap = {
                preset = "default",
                ["<C-k>"] = { "scroll_documentation_up", "fallback" },
                ["<C-j>"] = { "scroll_documentation_down", "fallback" },
            },

            completion = {
                list = { selection = { preselect = true, auto_insert = true } },
                accept = { auto_brackets = { enabled = false } },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    window = { border = "single" }
                },
                menu = {
                    border = "single",
                    draw = {
                        columns = { { "kind_icon", gap = 1, "label", "kind" } },
                    },

                },
            },

            sources = {
                default = {
                    "lsp",
                    "path",
                    "snippets",
                    "buffer",
                    "cmdline",
                    "omni",
                },

                per_filetype = {
                    php = { "laravel", inherit_defaults = true, },
                },

                providers = {
                    laravel = {
                        name = "laravel",
                        module = "blink.compat.source",
                        score_offset = 95, -- show at a higher priority than lsp
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
        }
    }
}
