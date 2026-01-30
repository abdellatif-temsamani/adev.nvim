local ui = require "adev-common.ui"

local M = {}

--- create a popup window to list files with help integrated
---@param buf integer buffer id
---@param height integer height of window
---@param width integer width of window
function M.create_win(buf, height, width)
    ui.window.floating_window {
        buf = buf,
        title = "Adev Files [?: help, q: quit]",
        width = width,
        height = height,
        border = "single",
        relative = "editor",
        wo = {
            cursorline = true,
            relativenumber = true,
            cursorlineopt = "line",
        },
    }
end

return M
