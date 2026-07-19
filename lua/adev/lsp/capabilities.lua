local M = {}

function M.build()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    local ok, blink = pcall(require, "blink.cmp")
    if ok then
        return blink.get_lsp_capabilities(capabilities)
    end
    return capabilities
end

return M
