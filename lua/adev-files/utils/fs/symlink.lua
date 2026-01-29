local uv = require "adev-files.utils.fs.uv"
local stat = require "adev-files.utils.fs.stat"

local M = {}

---@param src string
---@param dst string
---@return boolean, string?
function M.copy_symlink(src, dst)
    if not uv.fs_readlink or not uv.fs_symlink then
        return false, "symlink copy not supported"
    end
    if stat.exists(dst) then
        return false, "target exists: " .. dst
    end
    local target, err_name, err_msg = uv.fs_readlink(src)
    if not target then
        return false, (err_name or "fs_readlink") .. ": " .. (err_msg or "")
    end
    local ok, err_name2, err_msg2 = uv.fs_symlink(target, dst)
    if not ok then
        return false, (err_name2 or "fs_symlink") .. ": " .. (err_msg2 or "")
    end
    return true
end

return M
