return {
    {
        'nvim-flutter/flutter-tools.nvim',
        cond = function()
            return vim.fn.filereadable("pubspec.yaml") ~= 0
        end,
        event = require('abdellatifdev.consts').events.file,
        dependencies = {
            'nvim-lua/plenary.nvim',
        },
        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()

            local function on_attach(client, bufnr)
                if client.server_capabilities.documentSymbolProvider then
                    require("nvim-navic").attach(client, bufnr)
                end
            end


            require("flutter-tools").setup({
                debugger = { enabled = true, },
                outline = { auto_open = false },
                flutter_path = "/home/flagmate/.local/share/flutterup/bin/flutter",
                decorations = { statusline = { device = true, app_version = true } },
                widget_guides = { enabled = true, debug = true },
                dev_log = { enabled = false, open_cmd = "tabedit" },
                lsp = {
                    color = {
                        enabled = true,
                        background = false,
                        foreground = true,
                        background_color = nil,
                        virtual_text = true,
                        virtual_text_str = "■"
                    },
                    settings = {
                        showTodos = true,
                        completeFunctionCalls = true,
                        renameFilesWithClasses = "prompt", -- "always"
                        enableSnippets = true,
                        updateImportsOnRename = true,
                    },
                    capabilities = capabilities,
                    on_attach = on_attach,
                }
            })
        end
    },

    {
        'akinsho/pubspec-assist.nvim',
        event = require('abdellatifdev.consts').events.file,
        requires = 'plenary.nvim',
        opt = {}
    }

}
