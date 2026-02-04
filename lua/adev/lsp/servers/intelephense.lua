return function()
    -- NOTE: a secure way to handle licence key
    vim.lsp.config("intelephense", {
        settings = {
            intelephense = {
                files = {
                    maxSize = 2000000,
                },
            },
        },
        init_options = {
            licenceKey = vim.fn
                .system({ "cat", os.getenv "HOME" .. "/.secrets/intelephense" })
                :gsub("\n", ""),
        },
    })
end
