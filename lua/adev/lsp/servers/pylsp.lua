return function()
    vim.lsp.config("pylsp", {
        settings = {
            pylsp = {
                plugins = {
                    pycodestyle = { ignore = { "W391" }, maxLineLength = 120 },
                },
            },
        },
    })
end
