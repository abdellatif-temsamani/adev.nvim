return function()
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
end
