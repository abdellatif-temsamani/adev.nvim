local file_manager = require "adev-files.file_manager"
local M = {}

---@class FilesProps

---@type FilesProps
M.defaults = {}

---@param opts? FilesProps
function M.setup(opts)
    ---@type FilesProps
    opts = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

function M.open()
    file_manager.open()
end

return M
