local uv = vim.uv or vim.loop

local M = {}

local copy_dir = require "adev-files.utils.fs.copy_dir"
local copy_file = require "adev-files.utils.fs.copy_file"
local mkdir = require "adev-files.utils.fs.mkdir"
local stat = require "adev-files.utils.fs.stat"

M.stat = stat.stat
M.lstat = stat.lstat
M.exists = stat.exists

M.mkdir_p = mkdir.mkdir_p

M.copy_file = copy_file.copy_file
M.copy_dir_recursive = copy_dir.copy_dir_recursive

---@param path string
---@return boolean, string?
function M.create_empty_file(path)
    if M.exists(path) then
        return false, "already exists: " .. path
    end

    local parent = vim.fn.fnamemodify(path, ":h")
    if parent and parent ~= "" then
        local ok, err = M.mkdir_p(parent)
        if not ok then
            return false, err
        end
    end

    local fd, err_name, err_msg = uv.fs_open(path, "w", 420)
    if not fd then
        return false, (err_name or "fs_open") .. ": " .. (err_msg or "")
    end
    uv.fs_close(fd)
    return true
end

---@param path string
---@return boolean, string?
function M.rm_rf(path)
    local res = vim.fn.delete(path, "rf")
    if res ~= 0 then
        return false, "failed to delete: " .. path
    end
    return true
end

---@param src string
---@param dst string
---@return boolean, string?
function M.rename_path(src, dst)
    if M.exists(dst) then
        return false, "target exists: " .. dst
    end

    local parent = vim.fn.fnamemodify(dst, ":h")
    if parent and parent ~= "" then
        local ok, err = M.mkdir_p(parent)
        if not ok then
            return false, err
        end
    end

    local ok, err_name, err_msg = uv.fs_rename(src, dst)
    if not ok then
        return false, (err_name or "fs_rename") .. ": " .. (err_msg or "")
    end
    return true
end

return M
