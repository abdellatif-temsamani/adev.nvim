local path = require "adev-files.utils.fs.path"

local M = {}

local function display_name(entry)
    if entry.kind == "directory" then
        return entry.fs_name .. "/"
    end
    return entry.fs_name
end

---@param projection AdevFilesProjection
---@param pending_ops AdevFilesOp[]
---@return table<integer, AdevFilesOp>, table<string, boolean>, AdevFilesOp[]
local function normalize_pending(projection, pending_ops)
    local by_dst_id = {}
    local move_sources = {}
    local updated = {}

    for _, op in ipairs(pending_ops or {}) do
        if op.type == "copy" or op.type == "move" then
            local cloned = vim.deepcopy(op)
            if cloned.src then
                cloned.src = path.abs(cloned.src)
            end
            if cloned.dst then
                cloned.dst = path.abs(cloned.dst)
            end
            if not cloned.dst_id and cloned.dst then
                cloned.dst_id = projection.current_by_path[cloned.dst]
            end
            if cloned.dst_id then
                by_dst_id[cloned.dst_id] = cloned
                table.insert(updated, cloned)
            end
            if cloned.type == "move" and cloned.src then
                move_sources[cloned.src] = true
            end
        else
            table.insert(updated, op)
        end
    end

    return by_dst_id, move_sources, updated
end

---@param model AdevFilesModel
---@param projection AdevFilesProjection
---@param pending_ops AdevFilesOp[]
---@return AdevFilesOp[]|nil, string|nil, AdevFilesOp[]|nil
function M.plan(model, projection, pending_ops)
    if projection.errors and #projection.errors > 0 then
        return nil, projection.errors[1]
    end

    local ops = {}
    local pending_by_dst, move_sources, updated_pending =
        normalize_pending(projection, pending_ops or {})
    local original_by_path = model.original_by_path or {}
    local current_by_path = projection.current_by_path or {}

    for id, original in pairs(model.original_by_id or {}) do
        local current = projection.current_by_id[id]
        local deleted = projection.deleted_by_id[id] ~= nil
        if not current or deleted then
            if not current_by_path[original.abs_path] then
                if not move_sources[original.abs_path] then
                    table.insert(
                        ops,
                        { type = "delete", path = original.abs_path, kind = original.kind }
                    )
                end
            end
        else
            if current.abs_path == original.abs_path and current.entry.kind ~= original.kind then
                return nil,
                    "cannot change file/directory type in place: " .. display_name(current.entry)
            end
            if current.entry.fs_name ~= original.fs_name then
                table.insert(ops, {
                    type = "rename",
                    src = original.abs_path,
                    dst = current.abs_path,
                    kind = original.kind,
                })
            end
        end
    end

    for id, current in pairs(projection.current_by_id) do
        if not model.original_by_id[id] and not original_by_path[current.abs_path] then
            if not pending_by_dst[id] then
                if current.entry.kind == "directory" then
                    table.insert(
                        ops,
                        { type = "create", path = current.abs_path, kind = "directory" }
                    )
                else
                    table.insert(ops, { type = "create", path = current.abs_path, kind = "file" })
                end
            end
        end
    end

    for dst_id, op in pairs(pending_by_dst) do
        local current = projection.current_by_id[dst_id]
        if not current then
            return nil, "pending " .. op.type .. " destination no longer exists"
        end
        op.dst = current.abs_path
        table.insert(ops, { type = op.type, src = op.src, dst = op.dst, kind = op.kind })
    end

    return ops, nil, updated_pending
end

return M
