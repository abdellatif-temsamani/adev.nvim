return function()
    vim.lsp.config("lua_ls", {
        on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
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
end
