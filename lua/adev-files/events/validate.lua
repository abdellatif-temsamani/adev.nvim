local M = {}

---@param s string
---@return boolean, string?
function M.validate_rel_dir(s)
    s = (s or "")
    s = s:gsub("^%s+", ""):gsub("%s+$", "")
    if s == "" then
        return true, ""
    end
    if s:sub(1, 1) == "/" then
        return false, "path must be relative"
    end
    if s:find("\\", 1, true) or s:find("%z") or s:find("//", 1, true) then
        return false, "invalid path"
    end
    for seg in s:gmatch("[^/]+") do
        if seg == "." or seg == ".." then
            return false, "invalid segment: " .. seg
        end
    end
    return true, s
end

return M
