local file_manager = require "adev-files.file_manager"
local M = {}

---@class FilesProps
---@class FilesOpenFilesProps
---@field enabled boolean
---@field method 'edit'|'split'|'vsplit'|'tabedit'

---@type FilesProps
M.defaults = {
    open_files = {
        enabled = false,
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
    local ok, err = pcall(file_manager.open)
    if not ok then
        vim.notify("adev-files: " .. tostring(err), vim.log.levels.ERROR)
    end
end

return M
