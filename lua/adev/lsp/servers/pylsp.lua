return require("adev.lsp.servers.configure").server("pylsp", {
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = { ignore = { "W391" }, maxLineLength = 120 },
            },
        },
    },
})
