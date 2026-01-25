return function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    vim.diagnostic.config { virtual_text = { current_line = true } }

    local vim_capabilities = vim.lsp.protocol.make_client_capabilities()
    vim_capabilities.textDocument.completion.completionItem.snippetSupport = true

    local capabilities = require("blink.cmp").get_lsp_capabilities(vim_capabilities)

    vim.lsp.config("*", {
        capabilities = capabilities,
    })

    vim.lsp.config("lua_ls", {
        on_init = function(client)
            if client.workspace_folders then
                local path = client.workspace_folders[1].name
                if
                    path ~= vim.fn.stdpath "config"
                    and (
                        vim.uv.fs_stat(path .. "/.luarc.json")
                        or vim.uv.fs_stat(path .. "/.luarc.jsonc")
                    )
                then
                    return
                end
            end

            client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
                runtime = {
                    version = "LuaJIT",
                },
                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME,
                        "${3rd}/luv/library",
                        "${3rd}/busted/library",
                    },
                    -- NOTE: may switch to it later
                    -- library = vim.api.nvim_get_runtime_file("", true),
                },
            })
        end,
        settings = {
            Lua = {
                hint = {
                    enable = true,
                    setType = true,
                },
            },
        },
    })

    vim.lsp.config("tailwindcss", {
        settings = {
            tailwindCSS = {
                experimental = {
                    classRegex = {
                        -- cva("…")
                        { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
                        -- cn("…")
                        { "cn\\(([^)]*)\\)",  "[\"'`]([^\"'`]*)[\"'`]" },
                    },
                },
            },
        },
    })

    vim.lsp.config("vue_ls", {
        init_options = {
            typescript = {
                tsdk = os.getenv "HOME"
                    .. "/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib",
            },
        },
    })

    vim.lsp.config("emmet_ls", {
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
            "blade",
        },
    })

    vim.lsp.config("html", {
        filetypes = {
            "astro",
            "eruby",
            "html",
            "htmldjango",
            "templ",
            "blade",
        },
    })

    vim.lsp.config("pylsp", {
        settings = {
            pylsp = {
                plugins = {
                    pycodestyle = { ignore = { "W391" }, maxLineLength = 120 },
                },
            },
        },
    })

    vim.lsp.config("texlab", {
        filetypes = { "tex", "bib", "markdown", "plaintex" },
        on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
    })

    -- NOTE: a secure way to handle licence key
    vim.lsp.config("intelephense", {
        init_options = {
            licenceKey = vim.fn
                .system({ "cat", os.getenv "HOME" .. "/.secrets/intelephense" })
                :gsub("\n", ""),
        },
    })
end
