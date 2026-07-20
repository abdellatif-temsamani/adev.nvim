local marks = require "adev-files.core.marks"
local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"

local M = {}

---@param original_lines table<integer, {entry: AdevFilesEntry, abs_path: string}>
---@param current_entries {row: integer, entry: AdevFilesEntry, deleted: boolean}[]
---@param root string
---@param pending_ops AdevFilesOp[]
---@param buf integer
---@return AdevFilesOp[]|nil, string|nil, AdevFilesOp[]|nil
function M.plan(original_lines, current_entries, root, pending_ops, buf)
    local ops = {}
    local original_by_name = {}
    local original_by_path = {}
    local consumed_originals = {}

    for row, orig in pairs(original_lines) do
        local name = orig.entry.fs_name
        original_by_name[name] = original_by_name[name] or {}
        table.insert(original_by_name[name], { row = row, entry = orig.entry, abs_path = orig.abs_path })
        original_by_path[orig.abs_path] = row
    end

    local updated_pending = {}
    local pending_dst_paths = {}
    local pending_move_src_paths = {}
    local pending_delete_paths = {}
    for _, op in ipairs(pending_ops or {}) do
        if op.type == "delete" then
            local p = path.abs(op.path or "")
            if p ~= "" then
                pending_delete_paths[p] = true
                table.insert(ops, { type = "delete", path = p, kind = op.kind })
                table.insert(updated_pending, op)
            end
        elseif op.type == "copy" or op.type == "move" then
            local cloned = vim.deepcopy(op)
            if cloned.src then
                cloned.src = path.abs(cloned.src)
            end

            if cloned.dst_id and buf and vim.api.nvim_buf_is_valid(buf) then
                local row = marks.row_for_node(buf, cloned.dst_id)
                if row then
                    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
                    if line then
                        local clean = parse.strip_delete_marker(line)
                        local entry = select(1, parse.parse_line(clean))
                        if entry then
                            cloned.dst = path.join_abs(root, entry.fs_name)
                        end
                    end
                end
            end

            if cloned.dst then
                cloned.dst = path.abs(cloned.dst)
                pending_dst_paths[cloned.dst] = true
                if cloned.type == "move" and cloned.src then
                    pending_move_src_paths[cloned.src] = true
                end
                table.insert(ops, { type = op.type, src = cloned.src, dst = cloned.dst, kind = op.kind })
                table.insert(updated_pending, cloned)
            end
        else
            table.insert(updated_pending, op)
        end
    end

    local matched_current = {}

    for _, item in ipairs(current_entries) do
        if not item.deleted then
            local candidates = original_by_name[item.entry.fs_name]
            if candidates and #candidates > 0 then
                local match_idx
                for i, c in ipairs(candidates) do
                    if c.entry.kind == item.entry.kind then
                        match_idx = i
                        break
                    end
                end
                if match_idx then
                    local match = table.remove(candidates, match_idx)
                    consumed_originals[match.row] = true
                    matched_current[item.row] = true
                end
            end
        end
    end

    for _, item in ipairs(current_entries) do
        if not item.deleted and not matched_current[item.row] then
            local orig = original_lines[item.row]
            if orig and not consumed_originals[item.row] then
                consumed_originals[item.row] = true
                matched_current[item.row] = true
                if item.entry.fs_name ~= orig.entry.fs_name then
                    table.insert(ops, {
                        type = "rename",
                        src = orig.abs_path,
                        dst = path.join_abs(root, item.entry.fs_name),
                        kind = item.entry.kind,
                    })
                end
            else
                local abs_path = path.join_abs(root, item.entry.fs_name)
                if not pending_dst_paths[abs_path] then
                    table.insert(ops, {
                        type = "create",
                        path = abs_path,
                        kind = item.entry.kind,
                    })
                end
            end
        end
    end

    for row, orig in pairs(original_lines) do
        if not consumed_originals[row] then
            if not pending_move_src_paths[orig.abs_path] and not pending_delete_paths[orig.abs_path] then
                local still_exists = false
                for _, item in ipairs(current_entries) do
                    if not item.deleted and item.entry.fs_name == orig.entry.fs_name then
                        still_exists = true
                        break
                    end
                end
                if not still_exists then
                    table.insert(ops, {
                        type = "delete",
                        path = orig.abs_path,
                        kind = orig.entry.kind,
                    })
                end
            end
        end
    end

    return ops, nil, updated_pending
end

return M
