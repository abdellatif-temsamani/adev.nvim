local ui = require "adev-common.ui"

local M = {}

---@param root string
---@param total integer
---@return string
local function title_for_root(root, total)
    local suffix = (" [%d]"):format(total)
    return "Adev Files [" .. root .. "] [?: help]" .. suffix
end

---@param root string
---@return string
function M.escape_winbar_root(root)
    -- winbar is parsed as a statusline string, so literal percent signs must be doubled.
    return (root:gsub("%%", "%%%%"))
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
            conceallevel = 3,
            concealcursor = "nvic",
        },
    }
end

---@param buf integer
---@param root string
---@param total? integer
function M.set_title_from_state(buf, root, total)
    total = total or 0
    local title = title_for_root(root, total)
    local winbar = title_for_root(M.escape_winbar_root(root), total)
    local ok_mode, mode = pcall(vim.api.nvim_buf_get_var, buf, "adev_files_mode")
    for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win_id) and vim.api.nvim_win_get_buf(win_id) == buf then
            local ok, cfg = pcall(vim.api.nvim_win_get_config, win_id)
            if ok and cfg and cfg.relative ~= "" then
                cfg.title = title
                pcall(vim.api.nvim_win_set_config, win_id, cfg)
            elseif ok_mode and mode == "current" then
                pcall(function()
                    vim.wo[win_id].winbar = winbar
                end)
            end
            return
        end
    end
end

return M
