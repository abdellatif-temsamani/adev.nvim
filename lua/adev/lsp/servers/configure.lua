local M = {}

---@param client vim.lsp.Client
function M.disable_formatting(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
end

---@param name string
---@param opts table?
---@return fun()
function M.server(name, opts)
    return function()
        vim.lsp.config(name, opts or {})
    end
end

return M
