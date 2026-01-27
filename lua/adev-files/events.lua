---@class Events
---@field buf integer
local M = { buf = -1 }

--- create a new object
---@param buf number
function M.register(buf)
    assert(vim.api.nvim_buf_is_valid(buf), "not a valid buffer")

    ---Set a the buffer local keymap.
    ---@param modes string|string[] Mode(s) in which the mapping applies.
    ---@param lhs string            Left-hand side of the mapping (key sequence).
    ---@param rhs string|function   Right-hand side action or callback.
    local set_keymap = function(modes, lhs, rhs)
        vim.keymap.set(modes, lhs, rhs, { buffer = buf })
    end
    set_keymap("n", "<cr>", function()
        print(vim.api.nvim_get_current_line())
    end)
end

return M
