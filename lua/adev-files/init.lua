local file_manager = require "adev-files.file_manager"
local M = {}

---@class FilesProps

---@class FilesOpenFilesProps
---@field enabled boolean
---@field method 'edit'|'split'|'vsplit'|'tabedit'

---@type FilesProps
M.defaults = {
    open_files = {
        enabled = true,
        method = "edit",
    },
}

---@type FilesProps
M.config = vim.deepcopy(M.defaults)

---@param opts? FilesProps
function M.setup(opts)
    ---@type FilesProps
    opts = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
    M.config = opts
end

---@return FilesProps
function M.get_config()
    return M.config or M.defaults
end

function M.open()
    file_manager.open()
end

return M
