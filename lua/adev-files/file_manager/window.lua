local ui = require "adev-common.ui"

local M = {}

--- create a popup window to list files with help integrated
---@param buf integer buffer id
---@param height integer height of window
function M.create_win(buf, height)
    local width = 80

    if Snacks then
        Snacks.win {
            buf = buf,
            title = "Adev Files [?: help, q: quit]",
            width = width,
            height = height,
            border = "single",
            relative = "editor",
            wo = {
                cursorline = true,
                cursorlineopt = "line",
            },
        }
    else
        vim.keymap.set("", "q", "<cmd>bwipeout<CR>", { buffer = buf })

        vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            border = "single",
            title = "Adev Files [?: help, q: quit]",
            wo = {
                cursorline = true,
                cursorlineopt = "line",
            },
        })
    end
end

return M
