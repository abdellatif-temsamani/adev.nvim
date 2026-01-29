local M = {}

local function detect_filetype(name)
    local ok, ft = pcall(vim.filetype.match, { filename = name })
    if ok and ft and ft ~= "" then
        return ft
    end
    return nil
end

---@param name string
---@return string icon
---@return string hl
function M.get_icon(name)
    local ft = detect_filetype(name)
    if not ft then
        return "", ""
    end

    local ok, mini_icons = pcall(require, "mini.icons")
    if not ok then
        return "", ""
    end

    local icon, hl = mini_icons.get("filetype", ft)
    return icon or "", hl or ""
end

return M
