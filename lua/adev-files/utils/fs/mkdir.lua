local M = {}

---@param dir string
---@return boolean, string?
function M.mkdir_p(dir)
    if vim.fn.isdirectory(dir) == 1 then
        return true
    end
    local ok, result = pcall(vim.fn.mkdir, dir, "p")
    if not ok then
        return false, tostring(result)
    end
    if result ~= 1 and vim.fn.isdirectory(dir) ~= 1 then
        local detail = vim.v.errmsg
        if not detail or detail == "" then
            detail = "mkdir() returned " .. tostring(result)
        end
        return false, "failed to create directory: " .. dir .. ": " .. detail
    end
    return true
end

return M
