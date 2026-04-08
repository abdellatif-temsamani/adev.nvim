return function()
    local path = vim.fn.expand(vim.uv.os_homedir() .. "/.secrets/intelephense")
    local licenceKey = table.concat(vim.fn.readfile(path), "")

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
            licenceKey = licenceKey,
        },
    })
end
