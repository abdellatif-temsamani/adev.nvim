return require("adev.lsp.servers.configure").server("tailwindcss", {
    settings = {
        tailwindCSS = {
            experimental = {
                classRegex = {
                    -- cva("...")
                    { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
                    -- cn("...")
                    { "cn\\(([^)]*)\\)", "[\"'`]([^\"'`]*)[\"'`]" },
                },
            },
        },
    },
})
