local M = {}

local mini_icons

local function get_mini_icons()
    if mini_icons then
        return mini_icons
    end

    local ok, icons = pcall(require, "mini.icons")
    if not ok then
        return nil
    end

    mini_icons = icons
    return mini_icons
end

---@param category string
---@param name string
---@param fallback_icon? string
---@param fallback_hl? string
---@return string icon
---@return string hl
function M.get(category, name, fallback_icon, fallback_hl)
    local icons = get_mini_icons()
    if not icons then
        return fallback_icon or "", fallback_hl or ""
    end

    local icon, hl = icons.get(category, name)
    if not icon or icon == "" then
        return fallback_icon or "", fallback_hl or ""
    end

    return icon, hl or fallback_hl or ""
end

return M
