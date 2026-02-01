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
    local fallback_icon, fallback_hl = "f", "MiniFilesFile"
    local ft = detect_filetype(name)
    if not ft then
        return fallback_icon, fallback_hl
    end

    local ok, mini_icons = pcall(require, "mini.icons")
    if not ok then
        return fallback_icon, fallback_hl
    end

    local icon, hl = mini_icons.get("filetype", ft)
    if not icon or icon == "" then
        return fallback_icon, fallback_hl
    end
    return icon, hl or fallback_hl
end

return M
