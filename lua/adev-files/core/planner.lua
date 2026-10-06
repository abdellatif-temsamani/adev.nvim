local path = require "adev-files.utils.fs.path"

local M = {}

---@class AdevFilesRowChange
---@field original? AdevFilesNodeSnapshot
---@field op? AdevFilesOp

--- Compile one plan for both the display and the write handler. Entry identity
--- comes from the buffer text, never from an entry's current row number.
---@param model AdevFilesModel
---@param entries {row: integer, entry: AdevFilesEntry, deleted: boolean}[]
---@param pending_ops AdevFilesOp[]
---@return AdevFilesOp[]|nil, string?, AdevFilesOp[]?, table<integer, AdevFilesRowChange>?
function M.plan(model, entries, pending_ops)
    local ops, updated_pending, changes = {}, {}, {}
    local originals = model.original_by_id
    local by_id, seen_paths, pending_ids = {}, {}, {}
    local delete_paths, move_sources, destinations = {}, {}, {}

    for _, op in ipairs(pending_ops or {}) do
        if op.dst_id then
            pending_ids[op.dst_id] = op
        end
    end

    for _, item in ipairs(entries) do
        local entry = item.entry
        local abs = path.join_abs(model.root, entry.fs_name)
        if not item.deleted then
            if seen_paths[abs] then
                return nil, "duplicate path: " .. entry.fs_name
            end
            seen_paths[abs] = true
        end
        if entry.id then
            if not originals[entry.id] and not pending_ids[entry.id] then
                return nil, string.format("line %d: unknown entry ID", item.row + 1)
            end
            by_id[entry.id] = by_id[entry.id] or {}
            table.insert(by_id[entry.id], item)
        end
        changes[item.row] = { original = originals[entry.id] }
    end

    local function add(op, row)
        op.row = row
        table.insert(ops, op)
        if row then
            changes[row] = changes[row] or {}
            changes[row].op = op
        end
    end

    for _, op in ipairs(pending_ops or {}) do
        local cloned = vim.deepcopy(op)
        if cloned.type == "copy" or cloned.type == "move" then
            local items = cloned.dst_id and by_id[cloned.dst_id] or nil
            if items and #items > 1 then
                return nil, "pasted entry ID appears more than once"
            end
            local item = items and items[1] or nil
            if item and not item.deleted then
                cloned.dst = path.join_abs(model.root, item.entry.fs_name)
                cloned.src = path.abs(cloned.src)
                cloned.kind = item.entry.kind
                destinations[item.row] = true
                if cloned.type == "move" then
                    move_sources[cloned.src] = true
                end
                add({
                    type = cloned.type,
                    src = cloned.src,
                    dst = cloned.dst,
                    kind = cloned.kind,
                    dst_id = cloned.dst_id,
                }, item.row)
            elseif not cloned.dst_id and cloned.dst then
                -- Allow callers to stage operations without a buffer entry.
                cloned.src = path.abs(cloned.src)
                cloned.dst = path.abs(cloned.dst)
                if cloned.type == "move" then
                    move_sources[cloned.src] = true
                end
                add(vim.deepcopy(cloned))
            end
            -- Retain the intent so undoing removal of a destination restores it.
            -- Only destinations present in the buffer are included in the plan.
            table.insert(updated_pending, cloned)
        elseif cloned.type == "delete" then
            cloned.path = path.abs(cloned.path)
            delete_paths[cloned.path] = true
            table.insert(updated_pending, cloned)
        else
            return nil, "unsupported staged operation: " .. tostring(cloned.type)
        end
    end

    for _, id in ipairs(vim.tbl_keys(originals)) do
        local original = originals[id]
        local items = by_id[id] or {}
        local live = {}
        local retained
        for _, item in ipairs(items) do
            if not item.deleted and not delete_paths[original.abs_path] then
                if item.entry.kind ~= original.kind then
                    return nil, "cannot change entry type: " .. original.fs_name
                end
                if item.entry.fs_name == original.fs_name then
                    retained = item
                else
                    table.insert(live, item)
                end
            end
        end
        if move_sources[original.abs_path] then
            -- A staged move owns its source, even when the source row is marked.
        elseif delete_paths[original.abs_path] or (not retained and #live == 0) then
            local row = items[1] and items[1].row or nil
            add({ type = "delete", path = original.abs_path, kind = original.kind }, row)
            delete_paths[original.abs_path] = nil
        else
            for i, item in ipairs(live) do
                add({
                    type = not retained and i == 1 and "rename" or "copy",
                    src = original.abs_path,
                    dst = path.join_abs(model.root, item.entry.fs_name),
                    kind = original.kind,
                }, item.row)
            end
        end
    end

    for p in pairs(delete_paths) do
        local row
        for _, item in ipairs(entries) do
            if path.join_abs(model.root, item.entry.fs_name) == p then
                row = item.row
                break
            end
        end
        add({ type = "delete", path = p }, row)
    end

    for _, item in ipairs(entries) do
        if not item.entry.id and not item.deleted and not destinations[item.row] then
            local abs = path.join_abs(model.root, item.entry.fs_name)
            add({ type = "create", path = abs, kind = item.entry.kind }, item.row)
        end
    end

    table.sort(ops, function(a, b)
        local ak = (a.path or a.src or "") .. "\0" .. (a.dst or "") .. "\0" .. a.type
        local bk = (b.path or b.src or "") .. "\0" .. (b.dst or "") .. "\0" .. b.type
        return ak < bk
    end)
    return ops, nil, updated_pending, changes
end

return M
