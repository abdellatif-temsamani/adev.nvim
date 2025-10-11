return {
    "hrsh7th/nvim-cmp",
    event = require("adev.utils.consts").events:merge({ "cmd", "pre" }),
    dependencies = {
        { "saadparwaiz1/cmp_luasnip" },
        { "hrsh7th/cmp-path" },
        { "hrsh7th/cmp-buffer" },
        { "hrsh7th/cmp-calc" },
        { "hrsh7th/cmp-cmdline" },
        {
            "hrsh7th/cmp-nvim-lsp",
            event = require("adev.utils.consts").events.lsp,
        },
        {
            'davidsierradz/cmp-conventionalcommits',
            ft = "gitcommit",
            cond = function()
                return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("\n", "") == "true"
            end,
        },
        {
            'aspeddro/cmp-pandoc.nvim',
            ft = { "pandoc", "markdown", "rmd", "bib" },
            opts = {
                filetypes = { "pandoc", "markdown", "bib" },
                bibliography = {
                    documentation = true,
                    fields = { "type", "title", "author", "year" }
                },
                crossref = { documentation = true, enable_nabla = false }
            }
        },
        {
            "jc-doyle/cmp-pandoc-references",
            ft = { "pandoc", "markdown", "rmd", "bib" },
        },
        {
            "onsails/lspkind.nvim",
            opts = {
                mode = 'symbol_text',
            }
        }
    },
    opts = function(_, opts)
        local cmp = require("cmp")
        local lspkind = require('lspkind')
        local snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end
        }

        local mapping = cmp.mapping.preset.insert({
            ["<C-k>"] = cmp.mapping.scroll_docs(-2),
            ["<C-j>"] = cmp.mapping.scroll_docs(2),
            ["<C-Y>"] = cmp.mapping.confirm({ select = true })
        })
        local sources = cmp.config.sources({
            -- { name = "lazydev",  group_index = 0 },
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "path" },
            { name = "crates" },
            { name = "buffer" },
            { name = "calc" },
            { name = "latex_symbols" },
            { name = 'cmp_pandoc' },
            { name = "pandoc_references" },
        })

        local window = {
            completion = cmp.config.window.bordered(),
            documentation = cmp.config.window.bordered(),
        }

        local formatting = {
            format = lspkind.cmp_format({
                mode = 'symbol',
                maxwidth = {
                    menu = 30,
                    abbr = 30,
                },
                ellipsis_char = '...',
                show_labelDetails = true,

                before = function(entry, vim_item)
                    -- ...
                    return vim_item
                end
            })
        }

        opts.formatting = formatting
        opts.window = window
        opts.mapping = mapping
        opts.snippet = snippet
        opts.sources = sources

        cmp.setup.filetype("gitcommit", {
            sources = cmp.config.sources({
                { name = "cmp_git" },
                { name = "conventionalcommits" }
            }, { { name = "buffer" } })
        })
        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } }
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
                { name = "cmdline" },
            }
            )
        })
    end,
}
