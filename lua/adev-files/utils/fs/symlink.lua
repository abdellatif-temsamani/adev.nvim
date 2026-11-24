local path = require "adev-files.utils.fs.path"
local stat = require "adev-files.utils.fs.stat"
local uv = require "adev-files.utils.fs.uv"

local M = {}

---@param target string
---@return boolean
local function is_absolute(target)
    return target:sub(1, 1) == "/" or target:match "^%a:[\\/]" ~= nil
end

---@param src string
---@param dst string
---@param target string
---@return string
local function copied_target(src, dst, target)
    if is_absolute(target) then
        return target
    end
    -- A relative link is interpreted against the directory holding the link.
    -- When the copy lands in another directory, rebase it so it still resolves
    -- to the same file instead of pointing at a different (or missing) path.
    local src_dir = vim.fs.dirname(src)
    local dst_dir = vim.fs.dirname(dst)
    local abs_target = path.abs(path.join_abs(src_dir, target))
    local rel = path.relpath(dst_dir, abs_target)
    if not rel or rel == "" then
        return abs_target
    end
    return rel
end

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
    local new_target = copied_target(src, dst, target)
    local ok, err_name2, err_msg2 = uv.fs_symlink(new_target, dst)
    if not ok then
        return false, (err_name2 or "fs_symlink") .. ": " .. (err_msg2 or "")
    end
    return true
end

return M
