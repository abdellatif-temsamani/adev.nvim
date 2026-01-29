local M = {}

---@param s string
---@return string
function M.trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

return M
