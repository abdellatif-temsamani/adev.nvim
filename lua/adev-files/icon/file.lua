local M = {}
local icons = require "adev-common.icons"

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
    local fallback_icon, fallback_hl = "f", "Normal"
    local ft = detect_filetype(name)
    if not ft then
        return fallback_icon, fallback_hl
    end

    return icons.get("filetype", ft, fallback_icon, fallback_hl)
end

return M
