local M = {}

---@param name string
---@return string icon
---@return string hl
function M.get_icon(name)
    local ok, mini_icons = pcall(require, "mini.icons")
    if not ok then
        return "", ""
    end

    local icon, hl = mini_icons.get("directory", name)
    return icon or "", hl or ""
end

return M
