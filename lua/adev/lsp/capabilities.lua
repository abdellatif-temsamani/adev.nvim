local M = {}

function M.build()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    local blink = require "blink.cmp"
    return blink.get_lsp_capabilities(capabilities)
end

return M
