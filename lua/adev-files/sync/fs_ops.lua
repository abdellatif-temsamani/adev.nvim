local uv = vim.uv or vim.loop

local utils = require "adev-common.utils"

local M = {}

---@param path string
---@return boolean, string?
function M.mkdir_p(path)
    if utils.files.file_exists(path) and vim.fn.isdirectory(path) ~= 1 then
        return false, "path exists and is not a directory: " .. path
    end
    local ok, res = pcall(vim.fn.mkdir, path, "p")
    if not ok then
        return false, tostring(res)
    end
    return true
end

---@param path string
---@return boolean, string?
function M.create_empty_file(path)
    if utils.files.file_exists(path) then
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
    if utils.files.file_exists(dst) then
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
