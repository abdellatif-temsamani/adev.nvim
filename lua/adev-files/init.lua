local files = require "adev-files.actions"
local M = {}

---@class FilesProps
---@field keymaps boolean

---@type FilesProps
M.defaults = {
    keymaps = true,
}

---@param opts? FilesProps
function M.setup(opts)
    ---@type FilesProps
    opts = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
    assert(opts, "opts are nil")

    if opts.keymaps then
        files:setup_keymaps()
    end
end

return M
