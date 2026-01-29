return function()
    vim.lsp.config("texlab", {
        filetypes = { "tex", "bib", "markdown", "plaintex" },
        on_attach = function(client)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        end,
    })
end
