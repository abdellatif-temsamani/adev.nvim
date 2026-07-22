local fs = require "adev-files.utils.fs"
local fs_ops = require "adev-files.sync.fs_ops"
local path = require "adev-files.utils.fs.path"
local uv = require "adev-files.utils.fs.uv"

local M = {}

local VALID_TYPES = {
    copy = true,
    create = true,
    delete = true,
    move = true,
    rename = true,
}

---@param value any
---@param field string
---@param index integer
---@return string|nil, string|nil
local function required_path(value, field, index)
    if type(value) ~= "string" or value == "" then
        return nil, string.format("operation %d is missing %s", index, field)
    end
    return path.abs(value), nil
end

---@param ops AdevFilesOp[]
---@return AdevFilesOp[]|nil, string|nil
local function preflight(ops)
    if type(ops) ~= "table" then
        return nil, "operations must be a table"
    end

    local normalized = {}
    local vacated = {}
    local destructive_sources = {}
    local read_sources = {}

    for index, original in ipairs(ops) do
        if type(original) ~= "table" or not VALID_TYPES[original.type] then
            return nil, string.format("operation %d has an invalid type", index)
        end

        local op = vim.deepcopy(original)
        op._index = index

        if op.type == "delete" or op.type == "create" then
            local normalized_path, err = required_path(op.path, "path", index)
            if not normalized_path then
                return nil, err
            end
            op.path = normalized_path
        else
            local src, src_err = required_path(op.src, "src", index)
            if not src then
                return nil, src_err
            end
            local dst, dst_err = required_path(op.dst, "dst", index)
            if not dst then
                return nil, dst_err
            end
            if src == dst then
                return nil,
                    string.format(
                        "operation %d has identical source and destination: %s",
                        index,
                        src
                    )
            end
            op.src = src
            op.dst = dst
        end

        if op.type == "delete" then
            vacated[op.path] = true
            table.insert(destructive_sources, { path = op.path, index = index })
        elseif op.type == "rename" or op.type == "move" then
            vacated[op.src] = true
            table.insert(destructive_sources, { path = op.src, index = index })
        elseif op.type == "copy" then
            table.insert(read_sources, { path = op.src, index = index })
        end

        table.insert(normalized, op)
    end

    -- Staging nested destructive sources is ambiguous: moving the parent also
    -- moves the child. Reject the plan before touching disk.
    for i = 1, #destructive_sources do
        for j = i + 1, #destructive_sources do
            local a = destructive_sources[i]
            local b = destructive_sources[j]
            if
                path.is_same_or_subpath(a.path, b.path) or path.is_same_or_subpath(b.path, a.path)
            then
                return nil,
                    string.format("operations %d and %d have overlapping sources", a.index, b.index)
            end
        end
    end

    -- A copy source must stay stable for the whole transaction.
    for _, read in ipairs(read_sources) do
        for _, destructive in ipairs(destructive_sources) do
            if
                path.is_same_or_subpath(destructive.path, read.path)
                or path.is_same_or_subpath(read.path, destructive.path)
            then
                return nil,
                    string.format(
                        "operations %d and %d use conflicting sources",
                        read.index,
                        destructive.index
                    )
            end
        end
    end

    local destinations = {}
    local destination_list = {}
    for _, op in ipairs(normalized) do
        local src = op.src or op.path
        if op.type ~= "create" then
            local source_stat = fs.lstat(src)
            if not source_stat then
                return nil, "missing source: " .. src
            end
            op._source_stat = source_stat
        end

        local dst = op.type == "create" and op.path or op.dst
        if dst then
            if destinations[dst] then
                return nil,
                    string.format(
                        "operations %d and %d have the same destination: %s",
                        destinations[dst],
                        op._index,
                        dst
                    )
            end
            for _, other in ipairs(destination_list) do
                if path.is_subpath(other.path, dst) or path.is_subpath(dst, other.path) then
                    return nil,
                        string.format(
                            "operations %d and %d have nested destinations",
                            other.index,
                            op._index
                        )
                end
            end
            destinations[dst] = op._index
            table.insert(destination_list, { path = dst, index = op._index })

            if fs.exists(dst) and not vacated[dst] then
                return nil, "target exists: " .. dst
            end
        end

        if
            (op.type == "copy" or op.type == "move" or op.type == "rename")
            and op._source_stat.type == "directory"
            and path.is_same_or_subpath(op.src, op.dst)
        then
            return nil, "cannot copy or move a directory into itself: " .. op.dst
        end
    end

    return normalized, nil
end

---@param target string
---@return string
local function parent_dir(target)
    return vim.fs.dirname(target) or ""
end

---@param parent string
---@param name string
---@return string
local function join(parent, name)
    if parent == "/" then
        return "/" .. name
    end
    return parent .. "/" .. name
end

---@param source string
---@param seed string
---@param index integer
---@return string
local function staging_path(source, seed, index)
    local parent = parent_dir(source)
    local attempt = 0
    while true do
        local suffix = attempt == 0 and "" or ("-" .. attempt)
        local candidate = join(parent, ".adev-files-txn-" .. seed .. "-" .. index .. suffix)
        if not fs.exists(candidate) then
            return candidate
        end
        attempt = attempt + 1
    end
end

---@param target string
---@param created_dirs string[]
---@param created_set table<string, boolean>
---@return boolean, string?
local function ensure_parent_tracked(target, created_dirs, created_set)
    local parent = parent_dir(target)
    if parent == "" or vim.fn.isdirectory(parent) == 1 then
        return true
    end

    local missing = {}
    local cursor = parent
    while cursor ~= "" and not fs.exists(cursor) do
        table.insert(missing, 1, cursor)
        local next_parent = parent_dir(cursor)
        if next_parent == cursor then
            break
        end
        cursor = next_parent
    end

    if cursor ~= "" and fs.exists(cursor) and vim.fn.isdirectory(cursor) ~= 1 then
        return false, "parent is not a directory: " .. cursor
    end

    local ok, err = fs_ops.mkdir_p(parent)
    for _, dir in ipairs(missing) do
        if vim.fn.isdirectory(dir) == 1 and not created_set[dir] then
            created_set[dir] = true
            table.insert(created_dirs, dir)
        end
    end
    if not ok then
        return false, err
    end
    return true
end

---@param src string
---@param dst string
---@return boolean, string?
local function rename_path(src, dst)
    if fs.exists(dst) then
        return false, "target exists: " .. dst
    end
    local ok, err_name, err_msg = uv.fs_rename(src, dst)
    if not ok then
        return false, (err_name or "fs_rename") .. ": " .. (err_msg or "")
    end
    return true
end

---@param src string
---@param dst string
---@param source_stat uv.fs_stat.result
---@return boolean, string?
local function copy_path(src, dst, source_stat)
    if source_stat.type == "directory" then
        return fs.copy_dir_recursive(src, dst)
    end
    return fs.copy_file(src, dst)
end

---@param message string
---@param rollback_errors string[]
---@return boolean, string
local function failed(message, rollback_errors)
    if #rollback_errors == 0 then
        return false, message
    end
    return false, message .. "; rollback errors: " .. table.concat(rollback_errors, "; ")
end

---@param staged table[]
---@param created_paths string[]
---@param created_dirs string[]
---@return string[]
local function rollback(staged, created_paths, created_dirs)
    local errors = {}

    -- First move materialized destinations back to their staging paths. This
    -- two-phase rollback also handles swaps such as a -> b and b -> a.
    for i = #staged, 1, -1 do
        local item = staged[i]
        if item.materialized == "rename" and fs.exists(item.dst) then
            local ok, err = rename_path(item.dst, item.temp)
            if not ok then
                table.insert(errors, err or ("failed to unstage " .. item.dst))
            end
        elseif item.materialized == "copy" and fs.exists(item.dst) then
            local ok, err = fs_ops.rm_rf(item.dst)
            if not ok then
                table.insert(errors, err or ("failed to remove " .. item.dst))
            end
        end
    end

    for i = #created_paths, 1, -1 do
        local created = created_paths[i]
        if fs.exists(created) then
            local ok, err = fs_ops.rm_rf(created)
            if not ok then
                table.insert(errors, err or ("failed to remove " .. created))
            end
        end
    end

    for i = #staged, 1, -1 do
        local item = staged[i]
        if fs.exists(item.temp) then
            local ok, err = rename_path(item.temp, item.src)
            if not ok then
                table.insert(errors, err or ("failed to restore " .. item.src))
            end
        end
    end

    -- Only remove directories created by this transaction, and only when they
    -- are empty. Never recurse here: a concurrent writer may have used one.
    for i = #created_dirs, 1, -1 do
        local dir = created_dirs[i]
        if fs.exists(dir) then
            local ok, err_name, err_msg = uv.fs_rmdir(dir)
            if not ok and err_name ~= "ENOTEMPTY" and err_name ~= "EEXIST" then
                table.insert(errors, (err_name or "fs_rmdir") .. ": " .. (err_msg or dir))
            end
        end
    end

    return errors
end

---@param err string
---@return boolean
local function is_cross_device(err)
    return err:match "EXDEV" ~= nil or err:match "cross%-device" ~= nil
end

---@param ops AdevFilesOp[]
---@return boolean, string?
function M.apply_ops(ops)
    local planned, validation_err = preflight(ops)
    if not planned then
        return false, validation_err
    end
    if #planned == 0 then
        return true
    end

    local buckets = { delete = {}, rename = {}, copy = {}, move = {}, create = {} }
    for _, op in ipairs(planned) do
        table.insert(buckets[op.type], op)
    end

    local seed = tostring(uv.hrtime()):gsub("[^%w]", "")
    local staged = {}
    local staged_by_index = {}
    local created_paths = {}
    local created_dirs = {}
    local created_dir_set = {}

    local destructive = {}
    vim.list_extend(destructive, buckets.delete)
    vim.list_extend(destructive, buckets.rename)
    vim.list_extend(destructive, buckets.move)

    -- Vacate every destructive source before creating any destination. Besides
    -- making rollback possible, this safely supports rename swaps.
    for _, op in ipairs(destructive) do
        local src = op.type == "delete" and op.path or op.src
        local temp = staging_path(src, seed, op._index)
        local ok, err = rename_path(src, temp)
        if not ok then
            local rollback_errors = rollback(staged, created_paths, created_dirs)
            return failed(err or ("failed to stage " .. src), rollback_errors)
        end
        local item = { op = op, src = src, temp = temp, dst = op.dst, materialized = nil }
        table.insert(staged, item)
        staged_by_index[op._index] = item
    end

    local function abort(message)
        return failed(message, rollback(staged, created_paths, created_dirs))
    end

    for _, op in ipairs(buckets.rename) do
        local item = staged_by_index[op._index]
        local ok_parent, parent_err = ensure_parent_tracked(op.dst, created_dirs, created_dir_set)
        if not ok_parent then
            return abort(parent_err or ("failed to create parent for " .. op.dst))
        end
        local ok, err = rename_path(item.temp, op.dst)
        if not ok then
            return abort(err or ("failed to rename " .. op.src))
        end
        item.materialized = "rename"
    end

    for _, op in ipairs(buckets.copy) do
        local ok_parent, parent_err = ensure_parent_tracked(op.dst, created_dirs, created_dir_set)
        if not ok_parent then
            return abort(parent_err or ("failed to create parent for " .. op.dst))
        end
        if fs.exists(op.dst) then
            return abort("target exists: " .. op.dst)
        end
        table.insert(created_paths, op.dst)
        local ok, err = copy_path(op.src, op.dst, op._source_stat)
        if not ok then
            return abort(err or ("failed to copy " .. op.src))
        end
    end

    for _, op in ipairs(buckets.move) do
        local item = staged_by_index[op._index]
        local ok_parent, parent_err = ensure_parent_tracked(op.dst, created_dirs, created_dir_set)
        if not ok_parent then
            return abort(parent_err or ("failed to create parent for " .. op.dst))
        end
        if fs.exists(op.dst) then
            return abort("target exists: " .. op.dst)
        end
        local ok, err = rename_path(item.temp, op.dst)
        if ok then
            item.materialized = "rename"
        else
            if not is_cross_device(tostring(err or "")) then
                return abort(err or ("failed to move " .. op.src))
            end
            item.materialized = "copy"
            local copy_ok, copy_err = copy_path(item.temp, op.dst, op._source_stat)
            if not copy_ok then
                return abort(copy_err or ("failed to move " .. op.src))
            end
        end
    end

    for _, op in ipairs(buckets.create) do
        local ok_parent, parent_err = ensure_parent_tracked(op.path, created_dirs, created_dir_set)
        if not ok_parent then
            return abort(parent_err or ("failed to create parent for " .. op.path))
        end
        if fs.exists(op.path) then
            return abort("target exists: " .. op.path)
        end
        table.insert(created_paths, op.path)
        local ok, err
        if op.kind == "directory" then
            ok, err = fs_ops.mkdir_p(op.path)
        else
            ok, err = fs_ops.create_empty_file(op.path)
        end
        if not ok then
            return abort(err or ("failed to create " .. op.path))
        end
    end

    -- The visible transaction is now committed. Remove staged deletions and
    -- cross-device move sources. A cleanup failure is returned as a warning:
    -- rolling back after a recursive delete has started could itself lose data.
    local cleanup_errors = {}
    for _, item in ipairs(staged) do
        if fs.exists(item.temp) then
            local ok, err = fs_ops.rm_rf(item.temp)
            if not ok then
                table.insert(cleanup_errors, err or ("failed to clean " .. item.temp))
            end
        end
    end

    if #cleanup_errors > 0 then
        return true,
            "changes applied, but transaction cleanup failed: " .. table.concat(
                cleanup_errors,
                "; "
            )
    end
    return true
end

return M
