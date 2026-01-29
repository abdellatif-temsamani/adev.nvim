return function()
    vim.lsp.config("tailwindcss", {
        settings = {
            tailwindCSS = {
                experimental = {
                    classRegex = {
                        -- cva("…")
                        { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
                        -- cn("…")
                        { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
                    },
                },
            },
        },
    })
end
