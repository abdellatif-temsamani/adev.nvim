local M = {}

---@param buf integer
---@return fun(modes: string|string[], lhs: string, rhs: string|function, opts?: table)
function M.buffer(buf)
    return function(modes, lhs, rhs, opts)
        opts = vim.tbl_deep_extend("force", { buffer = buf }, opts or {})
        vim.keymap.set(modes, lhs, rhs, opts)
    end
end

return M
