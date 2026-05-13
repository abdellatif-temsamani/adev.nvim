local M = {}
local icons = require "adev-common.icons"

---@param name string
---@return string icon
---@return string hl
function M.get_icon(name)
    return icons.get("directory", name)
end

return M
