return {
    "neovim/nvim-lspconfig",
    -- dependencies = { 'saghen/blink.cmp' },
    module = false,
    event = require("abdellatifdev.consts").events.file,
    lazy = true,
    after = "williamboman/mason.nvim",
    config = function()
        ---@module "lspconfig"
        local lspconfig = require("lspconfig")

        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true


        local function on_attach(client, bufnr)
            if client.server_capabilities.documentSymbolProvider then
                require("nvim-navic").attach(client, bufnr)
            end
        end


        lspconfig.lua_ls.setup {
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
                            vim.env.VIMRUNTIME
                            -- "${3rd}/luv/library"
                            -- "${3rd}/busted/library",
                        }
                    }
                })
            end,
            settings = {
                Lua = {}
            }
        }

        lspconfig.astro.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.csharp_ls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.gopls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.eslint.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.svelte.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.slint_lsp.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.svlangserver.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.biome.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.volar.setup {
            capabilities = capabilities,
            on_attach = on_attach,
            init_options = {
                typescript = {
                    tsdk = '/home/flagmate/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib'
                },
            }
        }

        lspconfig.svls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.emmet_ls.setup {
            filetypes = { "astro", "css", "eruby", "html", "htmldjango", "javascriptreact", "less", "pug", "sass", "scss", "svelte", "typescriptreact", "vue", "htmlangular", "blade" },
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.bashls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.clangd.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.cmake.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.htmx.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.cssmodules_ls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.dockerls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.docker_compose_language_service.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.gdscript.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.html.setup {
            filetypes = { "astro", "css", "eruby", "html", "htmldjango", "templ", "blade" },
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.jsonls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }


        lspconfig.pyre.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.pylsp.setup {
            capabilities = capabilities,
            on_attach = on_attach,
            settings = {
                pylsp = {
                    plugins = {
                        pycodestyle = { ignore = { 'W391' }, maxLineLength = 100 }
                    }
                }
            }
        }

        lspconfig.pyright.setup {
            pabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.rust_analyzer.setup {
            apabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.sqlls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.ts_ls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.cssls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.css_variables.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.prismals.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.tailwindcss.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.taplo.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.zls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.solidity.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.solidity_ls_nomicfoundation.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.asm_lsp.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.yamlls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.lemminx.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.texlab.setup {
            filetypes = { "tex", "bib", "markdown", "plaintex" },
            capabilities = capabilities,
            on_attach = function(client, bufnr)
                on_attach(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end
        }


        lspconfig.gleam.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        -- lspconfig.vtsls.setup {
        --     capabilities = capabilities,
        -- }

        lspconfig.glslls.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.glsl_analyzer.setup {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        lspconfig.jdtls.setup({
            capabilities = capabilities,
            on_attach = on_attach,
        })

        -- NOTE: a secure way to handle licence key
        lspconfig.intelephense.setup {
            capabilities = capabilities,
            init_options = {
                licenceKey = vim.fn.system({ "cat", "/home/flagmate/.secrets/intelephense" }):gsub("\n", "")
            },
            on_attach = on_attach,
        }
    end
}
