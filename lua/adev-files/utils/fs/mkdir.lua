local M = {}

---@param dir string
---@return boolean, string?
function M.mkdir_p(dir)
    if vim.fn.isdirectory(dir) == 1 then
        return true
    end
    local ok, err = pcall(vim.fn.mkdir, dir, "p")
    if not ok then
        return false, tostring(err)
    end
    return true
end

return M
