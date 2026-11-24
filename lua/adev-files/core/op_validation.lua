local path = require "adev-files.utils.fs.path"

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
local function normalize(ops)
    local normalized = {}
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
            op.src = src
            op.dst = dst
        end

        table.insert(normalized, op)
    end
    return normalized
end

---@param base string
---@param child string
---@return boolean
local function is_subpath(base, child)
    return path.is_same_or_subpath(base, child) and base ~= child
end

--- Validate operation structure without touching the filesystem.
---
--- This catches conflicts early, when the user can still edit the buffer. The
--- executor repeats the filesystem-dependent checks before applying anything.
---@param ops AdevFilesOp[]
---@return AdevFilesOp[]|nil, string|nil
function M.validate_structural(ops)
    if type(ops) ~= "table" then
        return nil, "operations must be a table"
    end

    local normalized, err = normalize(ops)
    if not normalized then
        return nil, err
    end

    local destructive_sources = {}
    local read_sources = {}
    local relocations = {}
    local identical_copies = {}

    for _, op in ipairs(normalized) do
        if op.type == "delete" then
            table.insert(destructive_sources, { path = op.path, index = op._index })
        elseif op.type == "rename" or op.type == "move" then
            if op.src == op.dst then
                return nil,
                    string.format(
                        "operation %d has identical source and destination: %s",
                        op._index,
                        op.src
                    )
            end
            relocations[op.src] = op.dst
            table.insert(destructive_sources, { path = op.src, index = op._index })
        elseif op.type == "copy" then
            if op.src == op.dst then
                table.insert(identical_copies, op)
            end
            table.insert(read_sources, { path = op.src, index = op._index })
        end
    end

    -- A same-path copy is only meaningful when another operation relocates the
    -- source to a different live path. Without that, it is a no-op or would
    -- resurrect a deleted entry.
    for _, op in ipairs(identical_copies) do
        local destination = relocations[op.src]
        if not destination or destination == op.src then
            return nil,
                string.format(
                    "operation %d has identical source and destination: %s",
                    op._index,
                    op.src
                )
        end
    end

    -- Moving a parent relocates its children too, so nested destructive
    -- sources are ambiguous.
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

    -- Copies of a staged source read from its transaction snapshot. Nested
    -- sources still conflict because staging a parent relocates its children.
    for _, read in ipairs(read_sources) do
        for _, destructive in ipairs(destructive_sources) do
            if
                read.path ~= destructive.path
                and (
                    path.is_same_or_subpath(destructive.path, read.path)
                    or path.is_same_or_subpath(read.path, destructive.path)
                )
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
                local other_is_parent = is_subpath(other.path, dst)
                local current_is_parent = is_subpath(dst, other.path)
                local allowed = (
                    other_is_parent
                    and other.type == "create"
                    and other.kind == "directory"
                )
                    or (current_is_parent and op.type == "create" and op.kind == "directory")
                if (other_is_parent or current_is_parent) and not allowed then
                    return nil,
                        string.format(
                            "operations %d and %d have nested destinations",
                            other.index,
                            op._index
                        )
                end
            end
            destinations[dst] = op._index
            table.insert(
                destination_list,
                { path = dst, index = op._index, type = op.type, kind = op.kind }
            )
        end

        if
            dst
            and (op.type == "copy" or op.type == "move" or op.type == "rename")
            and op.kind == "directory"
            and path.is_same_or_subpath(op.src, dst)
        then
            local same_path_relocation = op.type == "copy"
                and op.src == op.dst
                and relocations[op.src]
                and relocations[op.src] ~= op.src
            if not same_path_relocation then
                return nil, "cannot copy or move a directory into itself: " .. dst
            end
        end
    end

    return normalized, nil
end

return M
