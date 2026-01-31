local directory_icons = require "adev-files.icon.directory"
local file_icons = require "adev-files.icon.file"

local M = {}

--- Get icon and highlight group for an entry
---@param entry string
---@return string icon
---@return string hl
function M.get_entry_icon(entry)
    if entry == "" then
        return "", ""
    end

    if entry:sub(-1) == "/" then
        local name = entry:sub(1, -2)
        return directory_icons.get_icon(name)
    end

    return file_icons.get_icon(entry)
end

---@param entry string
---@return string
function M.decorate_entry(entry)
    local icon = M.get_entry_icon(entry)
    local prefix = icon ~= "" and (icon .. " ") or "  "
    return prefix .. entry
end

return M
