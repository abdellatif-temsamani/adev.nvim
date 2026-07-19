local ui = require "adev-common.ui"

local M = {}

---@param root string
---@param total integer
---@return string
local function title_for_root(root, total)
    local suffix = (" [%d]"):format(total)
    return "Adev Files [" .. root .. "] [?: help]" .. suffix
end

--- create a popup window to list files with help integrated
---@param buf integer buffer id
---@param height integer height of window
---@param width integer width of window
---@param root string
function M.create_win(buf, height, width, root)
    ui.window.floating_window {
        buf = buf,
        title = title_for_root(root, 0),
        width = width,
        height = height,
        border = "single",
        relative = "editor",
        wo = {
            cursorline = true,
            cursorlineopt = "line",
        },
    }
end

---@param buf integer
---@param root string
---@param total integer
function M.set_title_from_state(buf, root, total)
    total = total or 0
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win_id) and vim.api.nvim_win_get_buf(win_id) == buf then
            local ok, cfg = pcall(vim.api.nvim_win_get_config, win_id)
            if ok and cfg then
                cfg.title = title_for_root(root, total)
                pcall(vim.api.nvim_win_set_config, win_id, cfg)
            end
            return
        end
    end
end

return M
