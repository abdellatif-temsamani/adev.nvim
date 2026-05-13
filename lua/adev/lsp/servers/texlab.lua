local config = require "adev.lsp.servers.configure"

return config.server("texlab", {
    filetypes = { "tex", "bib", "markdown", "plaintex" },
    on_attach = config.disable_formatting,
})
