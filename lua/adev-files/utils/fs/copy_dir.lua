local copy_file = require "adev-files.utils.fs.copy_file"
local mkdir = require "adev-files.utils.fs.mkdir"
local path = require "adev-files.utils.fs.path"
local stat = require "adev-files.utils.fs.stat"
local symlink = require "adev-files.utils.fs.symlink"
local uv = require "adev-files.utils.fs.uv"

local M = {}

---@param dir string
local function remove_partial(dir)
    pcall(vim.fn.delete, dir, "rf")
end

---@param src_dir string
---@param dst_dir string
---@return boolean, string?, boolean?
local function copy_dir(src_dir, dst_dir)
    if stat.exists(dst_dir) then
        return false, "target exists: " .. dst_dir
    end
    if path.is_same_or_subpath(src_dir, dst_dir) then
        return false, "cannot copy a directory into itself: " .. dst_dir
    end

    local ok_parent, parent_err = mkdir.mkdir_p(vim.fs.dirname(dst_dir))
    if not ok_parent then
        return false, parent_err
    end
    local ok, err = uv.fs_mkdir(dst_dir, 493)
    if not ok then
        return false, "fs_mkdir " .. dst_dir .. ": " .. tostring(err)
    end

    local fd, scan_err = uv.fs_scandir(src_dir)
    if not fd then
        return false, "fs_scandir " .. src_dir .. ": " .. tostring(scan_err), true
    end

    while true do
        local name, typ, next_err = uv.fs_scandir_next(fd)
        if not name then
            -- uv versions differ on which return slot carries the error.
            local detail = next_err or (type(typ) == "string" and typ or nil)
            if detail then
                return false, "fs_scandir_next " .. src_dir .. ": " .. tostring(detail), true
            end
            break
        end

        local src = path.join_abs(src_dir, name)
        local dst = path.join_abs(dst_dir, name)
        local copied, copy_err, created

        if typ == "directory" then
            copied, copy_err, created = copy_dir(src, dst)
        elseif typ == "file" then
            copied, copy_err, created = copy_file.copy_file(src, dst)
        elseif typ == "link" then
            copied, copy_err, created = symlink.copy_symlink(src, dst)
        else
            local st = stat.lstat(src)
            if st and st.type == "directory" then
                copied, copy_err, created = copy_dir(src, dst)
            elseif st and st.type == "file" then
                copied, copy_err, created = copy_file.copy_file(src, dst)
            elseif st and st.type == "link" then
                copied, copy_err, created = symlink.copy_symlink(src, dst)
            else
                return false, "unsupported entry type: " .. tostring(typ), true
            end
        end

        if not copied then
            return false, copy_err, true
        end
    end

    return true
end

---@param src_dir string
---@param dst_dir string
---@return boolean, string?, boolean?
function M.copy_dir_recursive(src_dir, dst_dir)
    local ok, err, created = copy_dir(src_dir, dst_dir)
    if not ok then
        if created then
            remove_partial(dst_dir)
        end
        return false, err, created
    end
    return true
end

return M
