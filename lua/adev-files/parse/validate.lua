local M = {}

---@param p string
---@return boolean
function M.is_valid_rel_path(p)
    if p == "" then
        return false
    end
    if p:sub(1, 1) == "/" then
        return false
    end
    if p:find("\\", 1, true) then
        return false
    end
    if p:find "%z" then
        return false
    end

    -- Reject empty segments, '.' and '..'
    for seg in p:gmatch "[^/]+" do
        if seg == "." or seg == ".." then
            return false
        end
    end
    if p:find("//", 1, true) then
        return false
    end
    return true
end

return M
