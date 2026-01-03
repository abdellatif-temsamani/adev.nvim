local M = {}

--- Checks if a file exists
---@param path string
---@return boolean
function M.file_exists(path)
    return vim.fn.filereadable(path) == 1
end

return M
