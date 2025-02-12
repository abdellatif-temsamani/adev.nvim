return {
    "hrsh7th/nvim-cmp",
    event = require("abdellatifdev.consts").events.file,
    opts = function(_, opts)
        local cmp = require("cmp")
        local snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end
        }
        local mapping = cmp.mapping.preset.insert({
            ["<C-k>"] = cmp.mapping.scroll_docs(-4),
            ["<C-j>"] = cmp.mapping.scroll_docs(4),
            ["<C-Y>"] = cmp.mapping.confirm({ select = true })
        })
        local sources = cmp.config.sources({
            { name = "lazydev",                group_index = 0 },
            { name = "nvim_lsp" },
            { name = "nvim_lua" },
            { name = "nvim_lsp_signature_help" },
            { name = "luasnip" },
            { name = "laravel" },
            { name = "path" },
            { name = "crates" },
            { name = "buffer" },
            { name = "calc" },
            { name = "latex_symbols" },
            { name = 'cmp_pandoc' },
            { name = "pandoc_references" },
        })
        opts.mapping = mapping
        opts.snippet = snippet
        opts.sources = sources
        -- Set configuration for specific filetype.
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
            sources = cmp.config.sources({ { name = "path" } },
                { { name = "cmdline" }, { name = "nvim_lua" } })
        })
    end,
}
