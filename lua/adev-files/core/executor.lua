local fs = require "adev-files.utils.fs"
local fs_ops = require "adev-files.sync.fs_ops"
local stat = require "adev-files.utils.fs.stat"

local M = {}

local function parent_dir(path)
    return path:match("^(.*)/[^/]+/?$") or ""
end

local function ensure_parent(path)
    local parent = parent_dir(path)
    if parent ~= "" then
        return fs_ops.mkdir_p(parent)
    end
    return true
end

local function ensure_available(path)
    if stat.exists(path) then
        return false, "target exists: " .. path
    end
    return true
end

---@param ops AdevFilesOp[]
---@return boolean, string?
function M.apply_ops(ops)
    local deletes_files = {}
    local deletes_dirs = {}
    local renames = {}
    local copies = {}
    local moves = {}
    local creates_dirs = {}
    local creates_files = {}

    for _, op in ipairs(ops) do
        if op.type == "delete" then
            if op.kind == "directory" then
                table.insert(deletes_dirs, op)
            else
                table.insert(deletes_files, op)
            end
        elseif op.type == "rename" then
            table.insert(renames, op)
        elseif op.type == "copy" then
            table.insert(copies, op)
        elseif op.type == "move" then
            table.insert(moves, op)
        elseif op.type == "create" then
            if op.kind == "directory" then
                table.insert(creates_dirs, op)
            else
                table.insert(creates_files, op)
            end
        end
    end

    for _, op in ipairs(renames) do
        local ok, err = ensure_parent(op.dst)
        if not ok then
            return false, err
        end
        local ok2, err2 = ensure_available(op.dst)
        if not ok2 then
            return false, err2
        end
    end
    for _, op in ipairs(copies) do
        local ok, err = ensure_parent(op.dst)
        if not ok then
            return false, err
        end
        local ok2, err2 = ensure_available(op.dst)
        if not ok2 then
            return false, err2
        end
    end
    for _, op in ipairs(moves) do
        local ok, err = ensure_parent(op.dst)
        if not ok then
            return false, err
        end
        local ok2, err2 = ensure_available(op.dst)
        if not ok2 then
            return false, err2
        end
    end
    for _, op in ipairs(creates_dirs) do
        local ok, err = ensure_parent(op.path)
        if not ok then
            return false, err
        end
    end
    for _, op in ipairs(creates_files) do
        local ok, err = ensure_parent(op.path)
        if not ok then
            return false, err
        end
    end

    for _, op in ipairs(deletes_files) do
        local ok, err = fs_ops.rm_rf(op.path)
        if not ok then
            return false, err
        end
    end
    for _, op in ipairs(deletes_dirs) do
        local ok, err = fs_ops.rm_rf(op.path)
        if not ok then
            return false, err
        end
    end

    for _, op in ipairs(renames) do
        local ok, err = fs_ops.rename_path(op.src, op.dst)
        if not ok then
            return false, err
        end
    end

    for _, op in ipairs(copies) do
        local st = fs.lstat(op.src)
        if not st then
            return false, "missing source: " .. op.src
        end
        if st.type == "directory" then
            local ok, err = fs.copy_dir_recursive(op.src, op.dst)
            if not ok then
                return false, err
            end
        else
            local ok, err = fs.copy_file(op.src, op.dst)
            if not ok then
                return false, err
            end
        end
    end

    for _, op in ipairs(moves) do
        local ok, err = fs_ops.rename_path(op.src, op.dst)
        if ok then
            goto continue
        end

        local err_s = tostring(err or "")
        if not err_s:match "EXDEV" and not err_s:match "cross%-device" then
            return false, err
        end

        local st = fs.lstat(op.src)
        if not st then
            return false, "missing source: " .. op.src
        end
        if st.type == "directory" then
            local ok2, err2 = fs.copy_dir_recursive(op.src, op.dst)
            if not ok2 then
                return false, err2
            end
        else
            local ok2, err2 = fs.copy_file(op.src, op.dst)
            if not ok2 then
                return false, err2
            end
        end
        local ok3, err3 = fs_ops.rm_rf(op.src)
        if not ok3 then
            return false, err3
        end

        ::continue::
    end

    for _, op in ipairs(creates_dirs) do
        local ok, err = fs_ops.mkdir_p(op.path)
        if not ok then
            return false, err
        end
    end

    for _, op in ipairs(creates_files) do
        local ok, err = fs_ops.create_empty_file(op.path)
        if not ok then
            return false, err
        end
    end

    return true
end

return M
