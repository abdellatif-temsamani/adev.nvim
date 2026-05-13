return function()
    local path = vim.fn.expand(vim.uv.os_homedir() .. "/.secrets/intelephense")

    local config = {
        settings = {
            intelephense = {
                files = {
                    maxSize = 2000000,
                },
            },
        },
    }

    if vim.fn.filereadable(path) == 1 then
        config.init_options = {
            licenceKey = table.concat(vim.fn.readfile(path), ""),
        }
    end

    vim.lsp.config("intelephense", config)
end
