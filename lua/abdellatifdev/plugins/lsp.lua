return {
    "neovim/nvim-lspconfig",
    -- dependencies = { 'saghen/blink.cmp' },
    module = false,
    event = require("abdellatifdev.consts").events.file,
    lazy = true,
    keys = {
        { "<leader>gl", function() vim.lsp.buf.format() end,                              desc = "lint buffer",         mode = { "v", "n" } },
        { "<leader>gd", function() vim.lsp.buf.definition() end,                          desc = "go to definition", },
        { "<leader>gD", function() vim.lsp.buf.declaration() end,                         desc = "go to declaration", },
        { "<leader>gh", function() vim.lsp.buf.hover() end,                               desc = "lsp hover", },
        { "<leader>gi", function() vim.lsp.buf.implementation() end,                      desc = "lsp implementation", },
        { "<leader>gr", function() vim.lsp.buf.references() end,                          desc = "lsp implementation", },
        { "<leader>gt", function() vim.lsp.buf.type_definition() end,                     desc = "lsp type definition", },
        { "<leader>gc", function() vim.lsp.buf.code_action() end,                         desc = "lsp code action",     mode = { "n", "v" } },
        { "<leader>gs", function() vim.lsp.buf.signature_help() end,                      desc = "lsp signature help", },
        { "<leader>go", function() vim.diagnostic.open_float() end,                       desc = "line diagnostic", },
        { "<leader>gp", function() vim.diagnostic.jump({ count = -1, float = true }) end, desc = "previous diagnostic", },
        { "<leader>gn", function() vim.diagnostic.jump({ count = 1, float = true }) end,  desc = "next diagnostic", },
        { "<leader>gr", function() vim.lsp.buf.rename() end,                              desc = "lsp rename", },
        { "<leader>gt", function() vim.lsp.buf.type_definition() end,                     desc = "lsp type definition", },
    },
    after = "williamboman/mason.nvim",
    config = function()
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true

        local function on_attach(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                require("nvim-navic").attach(client, bufnr)
            end
        end

        vim.lsp.config('*', {
            capabilities = capabilities,
            on_attach = on_attach,
        })

        vim.lsp.config('lua_ls', {
            on_init = function(client)
                if client.workspace_folders then
                    local path = client.workspace_folders[1].name
                    ---@diagnostic disable-next-line: undefined-field
                    if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then
                        return
                    end
                end
                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                    runtime = { version = 'LuaJIT' },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME,
                            "${3rd}/luv/library",
                            "${3rd}/busted/library",
                        }
                    }
                })
            end,
            settings = {
                Lua = {}
            }
        })

        vim.lsp.config('vue_ls', {
            init_options = {
                typescript = {
                    tsdk =
                    '/home/flagmate/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib'
                },
            }
        })

        vim.lsp.config('emmet_ls', {
            filetypes = {
                "astro",
                "css",
                "eruby",
                "html",
                "htmldjango",
                "javascriptreact",
                "less",
                "pug",
                "sass",
                "scss",
                "svelte",
                "typescriptreact",
                "vue",
                "htmlangular",
                "blade"
            },
        })

        vim.lsp.config('html', {
            filetypes = {
                "astro",
                "css",
                "eruby",
                "html",
                "htmldjango",
                "templ",
                "blade"
            },
        })

        vim.lsp.config('pylsp', {
            settings = {
                pylsp = {
                    plugins = {
                        pycodestyle = { ignore = { 'W391' }, maxLineLength = 100 }
                    }
                }
            }
        })

        vim.lsp.config('texlab', {
            filetypes = { "tex", "bib", "markdown", "plaintex" },
            on_attach = function(client, bufnr)
                on_attach(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end
        })

        -- NOTE: a secure way to handle licence key
        vim.lsp.config('intelephense', {
            init_options = {
                licenceKey = vim.fn.system({ "cat", "/home/flagmate/.secrets/intelephense" }):gsub("\n", "")
            },
        })

        vim.lsp.enable({
            "astro",
            "csharp_ls",
            "gopls",
            "eslint",
            "svelte",
            "slint_lsp",
            "svlangserver",
            "biome",
            "vue_ls",
            "svls",
            "emmet_ls",
            "bashls",
            "clangd",
            "cmake",
            "htmx",
            "cssmodules_ls",
            "dockerls",
            "docker_compose_language_service",
            "gdscript",
            "html",
            "jsonls",
            "pyre",
            "pylsp",
            "pyright",
            "rust_analyzer",
            "sqlls",
            "ts_ls",
            "cssls",
            "css_variables",
            "prismals",
            "tailwindcss",
            "taplo",
            "zls",
            "solidity",
            "solidity_ls_nomicfoundation",
            "asm_lsp",
            "yamlls",
            "lemminx",
            "texlab",
            "gleam",
            "glslls",
            "glsl_analyzer",
            "jdtls",
            "intelephense",
            "lua_ls",
        })
    end
}
