local clipboard = require "adev-files.clipboard"
local index = require "adev-files.sync.index"
local marks = require "adev-files.core.marks"
local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local state = require "adev-files.state"

local M = {}

---@param buf integer
function M.revert_current_line(buf)
    local st = state.get(buf)
    if not st or st.applying or st.confirming or st.needs_refresh then
        return
    end
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    if row < 1 then
        return
    end
    index.restore_ids(buf)
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
    local _, id = parse.strip_id(line)
    local original = st.model.original_by_id[id]
    local entry = parse.parse_line(line)
    local _, _, changes = plan.plan_ops(buf)
    local change = changes and changes[row]
    local duplicate_copy = change and change.op and change.op.type == "copy" and original
    local abs = original and original.abs_path or (entry and path.join_abs(st.root, entry.fs_name))
    if abs then
        clipboard.remove_by_src(abs)
    end

    local kept, remove_rows = {}, {}
    for _, op in ipairs(state.get_pending_ops(buf)) do
        local destination = op.dst_id and op.dst_id == id
        local source = op.type == "move" and abs and path.abs(op.src) == abs
        local deleted = op.type == "delete" and abs and path.abs(op.path) == abs
        if destination or source then
            local destination_row = op.dst_id and marks.row_for_node(buf, op.dst_id)
            if destination_row then
                remove_rows[destination_row] = true
            end
        elseif not deleted then
            table.insert(kept, op)
        end
    end
    state.set_pending_ops(buf, kept)

    if original and not duplicate_copy then
        local name = parse.format_name(original.fs_name)
            .. (original.kind == "directory" and "/" or "")
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { parse.with_id(name, id) })
    else
        remove_rows[row] = true
    end

    local rows = vim.tbl_keys(remove_rows)
    table.sort(rows, function(a, b)
        return a > b
    end)
    for _, target in ipairs(rows) do
        vim.api.nvim_buf_set_lines(buf, target, target + 1, false, {})
    end
    render.add_virtual_text(buf, st.root)
end

return M
