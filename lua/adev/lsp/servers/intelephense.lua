return function()
    -- NOTE: a secure way to handle licence key
    vim.lsp.config("intelephense", {
        init_options = {
            licenceKey = vim.fn
                .system({ "cat", os.getenv "HOME" .. "/.secrets/intelephense" })
                :gsub("\n", ""),
        },
    })
end
