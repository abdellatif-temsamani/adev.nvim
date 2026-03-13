local ui = require "adev-common.ui"

local M = {}

---@param root string
---@return string
local function title_for_root(root)
    return "Adev Files [" .. root .. "] [?: help, q: quit]"
end

--- create a popup window to list files with help integrated
---@param buf integer buffer id
---@param height integer height of window
---@param width integer width of window
---@param root string
function M.create_win(buf, height, width, root)
    ui.window.floating_window {
        buf = buf,
        title = title_for_root(root),
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

---@param win integer
---@param root string
function M.set_title(win, root)
    if not (win and vim.api.nvim_win_is_valid(win)) then
        return
    end

    local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
    if not ok or not cfg then
        return
    end

    cfg.title = title_for_root(root)
    pcall(vim.api.nvim_win_set_config, win, cfg)
end

return M
