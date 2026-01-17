local events = require "adev-common.utils.events"

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
            "nvim-mini/mini.icons",
        },
        event = { events.cmd.enter, events.insert.enter },
        version = "1.*",
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            cmdline = {
                enabled = true,
                keymap = { preset = "cmdline" },
                completion = {
                    ghost_text = { enabled = true },
                    menu = { auto_show = true },
                },
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
                trigger = {
                    show_on_keyword = true,
                    show_on_trigger_character = true,
                    show_on_insert_on_trigger_character = true,
                    show_on_accept_on_trigger_character = true,
                },

                list = {
                    selection = {
                        preselect = true,
                        auto_insert = true,
                    },
                },

                accept = {
                    auto_brackets = { enabled = false },
                },

                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 500,
                    window = { border = nil },
                },

                ghost_text = { enabled = true },

                menu = {
                    border = nil,
                    draw = {
                        columns = {
                            { "kind_icon", gap = 1, "label", "kind" },
                        },

                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    local ok, icons = pcall(require, "mini.icons")
                                    if not ok then
                                        return ""
                                    end
                                    return select(1, icons.get("lsp", ctx.kind))
                                end,
                                highlight = function(ctx)
                                    local ok, icons = pcall(require, "mini.icons")
                                    if not ok then
                                        return nil
                                    end
                                    return select(2, icons.get("lsp", ctx.kind))
                                end,
                            },

                            kind = {
                                highlight = function(ctx)
                                    local ok, icons = pcall(require, "mini.icons")
                                    if not ok then
                                        return nil
                                    end
                                    return select(2, icons.get("lsp", ctx.kind))
                                end,
                            },
                        },
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
            },
        },
        opts_extend = { "sources.default" },
    },
}
