local keymaps = require "adev-files.events.keymaps"
local sync = require "adev-files.sync"

local M = {}

---@param buf number
---@param root string
---@param opts? { disable_global_actions: boolean? }
function M.register(buf, root, opts)
    assert(vim.api.nvim_buf_is_valid(buf), "not a valid buffer")
    keymaps.attach(buf, opts)
    sync.attach(buf, root)
end

return M
