local copy_file = require "adev-files.utils.fs.copy_file"
local mkdir = require "adev-files.utils.fs.mkdir"
local path = require "adev-files.utils.fs.path"
local stat = require "adev-files.utils.fs.stat"
local symlink = require "adev-files.utils.fs.symlink"
local uv = require "adev-files.utils.fs.uv"

local M = {}

---@param src_dir string
---@param dst_dir string
---@return boolean, string?
function M.copy_dir_recursive(src_dir, dst_dir)
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
        return false, tostring(err)
    end

    local fd, scan_err = uv.fs_scandir(src_dir)
    if not fd then
        return false, "fs_scandir: " .. tostring(scan_err), true
    end

    while true do
        local name, typ = uv.fs_scandir_next(fd)
        if not name then
            break
        end

        local src = src_dir .. "/" .. name
        local dst = dst_dir .. "/" .. name

        if typ == "directory" then
            local ok2, err2 = M.copy_dir_recursive(src, dst)
            if not ok2 then
                return false, err2, true
            end
        elseif typ == "file" then
            local ok2, err2 = copy_file.copy_file(src, dst)
            if not ok2 then
                return false, err2, true
            end
        elseif typ == "link" then
            local ok2, err2 = symlink.copy_symlink(src, dst)
            if not ok2 then
                return false, err2, true
            end
        else
            local st = stat.lstat(src)
            if st and st.type == "directory" then
                local ok2, err2 = M.copy_dir_recursive(src, dst)
                if not ok2 then
                    return false, err2, true
                end
            elseif st and st.type == "file" then
                local ok2, err2 = copy_file.copy_file(src, dst)
                if not ok2 then
                    return false, err2, true
                end
            elseif st and st.type == "link" then
                local ok2, err2 = symlink.copy_symlink(src, dst)
                if not ok2 then
                    return false, err2, true
                end
            else
                return false, "unsupported entry type: " .. tostring(typ), true
            end
        end
    end

    return true
end

return M
