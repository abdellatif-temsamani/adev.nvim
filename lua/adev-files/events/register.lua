local keymaps = require "adev-files.events.keymaps"
local sync = require "adev-files.sync"

local M = {}

---@param buf number
---@param root string
function M.register(buf, root)
    assert(vim.api.nvim_buf_is_valid(buf), "not a valid buffer")
    keymaps.attach(buf)
    sync.attach(buf, root)
end

return M
