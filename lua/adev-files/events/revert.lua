local parse = require "adev-files.parse"
local state = require "adev-files.state"
local view = require "adev-files.core.view"
local marks = require "adev-files.core.marks"

local M = {}

---@param buf integer
---@param node_id integer|nil
---@param abs_path string|nil
---@return AdevFilesOp[]
local function remove_pending_ops_at_row(buf, node_id, abs_path)
    local pending = state.get_pending_ops(buf)
    if not pending or #pending == 0 then
        return {}
    end

    local updated = {}
    local removed = {}
    for _, op in ipairs(pending) do
        if (op.type == "copy" or op.type == "move") and (
            (node_id and op.dst_id == node_id) or (abs_path and op.dst == abs_path)
        ) then
            table.insert(removed, op)
        else
            table.insert(updated, op)
        end
    end

    if #removed > 0 then
        state.set_pending_ops(buf, updated)
    end

    return removed
end

---@param buf integer
---@param st AdevFilesState
---@param ops AdevFilesOp[]
local function restore_move_sources(buf, st, ops)
    if not st or not ops or #ops == 0 then
        return
    end

    local targets = {}
    for _, op in ipairs(ops) do
        if op.type == "move" and op.src then
            targets[op.src] = true
        end
    end
    if next(targets) == nil then
        return
    end

    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i, line in ipairs(lines) do
        local clean, is_deleted = parse.strip_delete_marker(line)
        if is_deleted then
            local entry = select(1, parse.parse_line(clean))
            if entry then
                local abs = st.root .. entry.fs_name
                if targets[abs] then
                    vim.api.nvim_buf_set_lines(buf, i - 1, i, false, { clean })
                end
            end
        end
    end
end

---@param buf integer
function M.revert_current_line(buf)
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
    local clean, is_deleted = parse.strip_delete_marker(line)

    local st = state.get(buf)
    if not st then
        return
    end

    local entries, err = view.parse_buffer(buf)
    if err then
        return
    end
    local row_to_id = marks.sync(buf, entries)
    local node_id = row_to_id[row]
    local row_entry = nil
    for _, item in ipairs(entries) do
        if item.row == row then
            row_entry = item.entry
            break
        end
    end
    local abs_path = row_entry and (st.root .. row_entry.fs_name) or nil

    local removed_ops = remove_pending_ops_at_row(buf, node_id, abs_path)
    if #removed_ops > 0 then
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {})
        restore_move_sources(buf, st, removed_ops)
        return
    end

    if is_deleted then
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { clean })
        return
    end

    local original = node_id and st.model and st.model.original_by_id[node_id] or nil
    if original then
        local entry = select(1, parse.parse_line(clean))
        if entry and entry.fs_name ~= original.fs_name then
            local display = original.fs_name
            if original.kind == "directory" then
                display = original.fs_name .. "/"
            end
            vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { display })
        end
        return
    end

    -- New line (create or pasted dest) - remove it
    vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {})
end

return M
