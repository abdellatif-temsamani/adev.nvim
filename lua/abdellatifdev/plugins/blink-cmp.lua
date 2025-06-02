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
        opts = function()
            local plugins = require("lazy.core.config").plugins
            local lazydev_enabled = plugins["lazydev.nvim"] ~= nil and plugins["lazydev.nvim"].cond()

            return {
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
                        lua = lazydev_enabled
                            and { inherit_defaults = true, 'lazydev' }
                            or { inherit_defaults = true },
                    },
                    providers = vim.tbl_extend("force", {
                        laravel = {
                            name = "laravel",
                            module = "blink.compat.source",
                        },
                    }, lazydev_enabled and {
                        lazydev = {
                            name = "LazyDev",
                            module = "lazydev.integrations.blink",
                            score_offset = 100,
                        }
                    } or {}),
                },

                snippets = { preset = 'luasnip' },
                signature = { enabled = true },
                opts_extend = { "sources.default" },
            }
        end
    }
}
