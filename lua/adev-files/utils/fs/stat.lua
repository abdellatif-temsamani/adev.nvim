local uv = require "adev-files.utils.fs.uv"

local M = {}

---@param path string
---@return uv.fs_stat.result|nil
function M.stat(path)
    return uv.fs_stat(path)
end

---@param path string
---@return uv.fs_stat.result|nil
function M.lstat(path)
    return uv.fs_lstat(path)
end

---@param path string
---@return boolean
function M.exists(path)
    return uv.fs_stat(path) ~= nil
end

return M
