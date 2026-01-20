local M = {}

---@class FilesProps

---@type FilesProps
M.defaults = {}

---@param opts? FilesProps
function M.setup(opts)
    ---@type FilesProps
    opts = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
end

return M
