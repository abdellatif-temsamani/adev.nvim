local utils = require "adev-common.utils"

local confirmation = require "adev-files.utils.confirmation"
local fs = require "adev-files.utils.fs"

local fmt = require "adev-files.sync.format"
local fs_ops = require "adev-files.sync.fs_ops"
local state = require "adev-files.state"
local view = require "adev-files.sync.view"

local M = {}

---@param ops AdevFilesOp[]
---@return integer
local function count_fs_ops(ops)
    local n = 0
    for _, _ in ipairs(ops) do
        n = n + 1
    end
    return n
end

---@param ops AdevFilesOp[]
---@return boolean, string?
local function apply_ops(ops)
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

    -- delete first (allows renames into deleted targets)
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
        if not err_s:match("EXDEV") and not err_s:match("cross%-device") then
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

---@class AdevFilesApplyOpts
---@field title? string
---@field preface? string[]
---@field on_success? fun(): nil
---@field on_cancel? fun(): nil

---@param buf integer
---@param ops AdevFilesOp[]
---@param opts? AdevFilesApplyOpts
function M.apply_ops_with_confirm(buf, ops, opts)
    opts = opts or {}
    local st = state.get(buf)
    if not st or st.applying then
        return
    end

    local fs_n = count_fs_ops(ops)
    if fs_n == 0 then
        view.refresh(buf)
        return
    end

    local lines = fmt.format_ops(st, ops)
    if opts.preface and #opts.preface > 0 then
        local merged = {}
        for _, l in ipairs(opts.preface) do
            table.insert(merged, l)
        end
        table.insert(merged, "")
        for _, l in ipairs(lines) do
            table.insert(merged, l)
        end
        lines = merged
    end

    confirmation.open(lines, { title = opts.title or "adev-files" }, function(confirmed)
        if not confirmed then
            if opts.on_cancel then
                opts.on_cancel()
            end
            utils.notify("Cancelled", vim.log.levels.INFO, "adev-files")
            return
        end

        local st2 = state.get(buf)
        if not st2 or st2.applying then
            return
        end

        st2.applying = true
        local ok, apply_err = apply_ops(ops)
        st2.applying = false

        if not ok then
            utils.err_notify(apply_err or "failed to apply changes", "adev-files")
            return
        end

        -- Refresh after clearing `applying`, otherwise refresh is a no-op.
        view.refresh(buf)
        if opts.on_success then
            opts.on_success()
        end
    end)
end

return M
