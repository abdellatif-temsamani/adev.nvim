local uv = require "adev-files.utils.fs.uv"
local mkdir = require "adev-files.utils.fs.mkdir"
local stat = require "adev-files.utils.fs.stat"
local symlink = require "adev-files.utils.fs.symlink"

local M = {}

---@param src string
---@param dst string
---@return boolean, string?
function M.copy_file(src, dst)
    if stat.exists(dst) then
        return false, "target exists: " .. dst
    end

    local st = stat.lstat(src)
    if st and st.type == "link" then
        return symlink.copy_symlink(src, dst)
    end

    local parent = vim.fn.fnamemodify(dst, ":h")
    if parent and parent ~= "" then
        local ok, err = mkdir.mkdir_p(parent)
        if not ok then
            return false, err
        end
    end

    if uv.fs_copyfile then
        local ok, err_name, err_msg = uv.fs_copyfile(src, dst)
        if not ok then
            return false, (err_name or "fs_copyfile") .. ": " .. (err_msg or "")
        end
        return true
    end

    local in_fd, in_err_name, in_err_msg = uv.fs_open(src, "r", 438)
    if not in_fd then
        return false, (in_err_name or "fs_open") .. ": " .. (in_err_msg or "")
    end
    local out_fd, out_err_name, out_err_msg = uv.fs_open(dst, "w", 420)
    if not out_fd then
        uv.fs_close(in_fd)
        return false, (out_err_name or "fs_open") .. ": " .. (out_err_msg or "")
    end

    local off = 0
    local chunk = 64 * 1024
    while true do
        local data, read_err_name, read_err_msg = uv.fs_read(in_fd, chunk, off)
        if not data then
            uv.fs_close(in_fd)
            uv.fs_close(out_fd)
            return false, (read_err_name or "fs_read") .. ": " .. (read_err_msg or "")
        end
        if data == "" then
            break
        end
        local _, write_err_name, write_err_msg = uv.fs_write(out_fd, data, off)
        if write_err_name then
            uv.fs_close(in_fd)
            uv.fs_close(out_fd)
            return false, (write_err_name or "fs_write") .. ": " .. (write_err_msg or "")
        end
        off = off + #data
    end

    uv.fs_close(in_fd)
    uv.fs_close(out_fd)
    return true
end

return M
