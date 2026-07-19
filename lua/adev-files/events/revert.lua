local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@param abs_path string|nil
---@return AdevFilesOp[]
local function remove_pending_ops_at_path(buf, abs_path)
    local pending = state.get_pending_ops(buf)
    if not pending or #pending == 0 then
        return {}
    end

    local updated = {}
    local removed = {}
    for _, op in ipairs(pending) do
        local op_dst = op.dst and path.abs(op.dst) or nil
        if
            (op.type == "copy" or op.type == "move")
            and (abs_path and op_dst == abs_path)
        then
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
            targets[path.abs(op.src)] = true
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
                local abs = path.join_abs(st.root, entry.fs_name)
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

    local entry = select(1, parse.parse_line(clean))
    local abs_path = entry and path.join_abs(st.root, entry.fs_name) or nil

    local removed_ops = remove_pending_ops_at_path(buf, abs_path)
    if #removed_ops > 0 then
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {})
        restore_move_sources(buf, st, removed_ops)
        return
    end

    if is_deleted then
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { clean })
        return
    end

    local original_lines = state.get_original_lines(buf)
    local original = original_lines[row]
    if original then
        if entry and entry.fs_name ~= original.entry.fs_name then
            local display = original.entry.fs_name
            if original.entry.kind == "directory" then
                display = original.entry.fs_name .. "/"
            end
            vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { display })
        end
        return
    end

    if not entry then
        return
    end
    vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {})
end

return M
