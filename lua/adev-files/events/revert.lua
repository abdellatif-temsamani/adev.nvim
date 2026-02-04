local parse = require "adev-files.parse"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@return table<integer, AdevFilesMark>, AdevFilesState|nil
local function build_marks_by_row(buf)
    local st = state.get(buf)
    if not st or not st.original_marks then
        return {}, st
    end

    local mark_ns = state.ns()
    local marks_by_row = {}
    local extmarks = vim.api.nvim_buf_get_extmarks(buf, mark_ns, 0, -1, {})
    for _, m in ipairs(extmarks) do
        local id, row = m[1], m[2]
        marks_by_row[row] = st.original_marks[id]
    end

    return marks_by_row, st
end

---@param buf integer
---@param row integer
---@return AdevFilesOp[]
local function remove_pending_ops_at_row(buf, row)
    local pending = state.get_pending_ops(buf)
    if not pending or #pending == 0 then
        return {}
    end

    local pending_ns = state.pending_ns()
    local updated = {}
    local removed = {}
    for _, op in ipairs(pending) do
        if (op.type == "copy" or op.type == "move") and op.mark_id then
            local pos = vim.api.nvim_buf_get_extmark_by_id(buf, pending_ns, op.mark_id, {})
            if pos and #pos > 0 and pos[1] == row then
                table.insert(removed, op)
                pcall(vim.api.nvim_buf_del_extmark, buf, pending_ns, op.mark_id)
            else
                table.insert(updated, op)
            end
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

    local marks_by_row, st = build_marks_by_row(buf)
    if not st then
        return
    end

    local removed_ops = remove_pending_ops_at_row(buf, row)
    if #removed_ops > 0 then
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {})
        restore_move_sources(buf, st, removed_ops)
        return
    end

    if is_deleted then
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { clean })
        return
    end

    local mark = marks_by_row[row]
    if mark then
        local entry = select(1, parse.parse_line(clean))
        if entry and entry.fs_name ~= mark.fs_name then
            vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { mark.name })
        end
        return
    end

    -- New line (create or pasted dest) - remove it
    vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {})
end

return M
