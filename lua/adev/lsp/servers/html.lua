return function()
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
end
