local parse = require "adev-files.parse"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local selection = require "adev-files.events.selection"
local state = require "adev-files.state"

local M = {}

---@param buf integer
function M.delete_selected(buf)
    local st = state.get(buf)
    if not st or st.applying or st.confirming or st.needs_refresh then
        return
    end

    local items, rows = selection.collect_entries_with_rows(buf)
    if #items == 0 or #rows == 0 then
        return
    end

    local ops = {}
    local remove_rows = {}
    local _, _, changes = plan.plan_ops(buf)
    for i, item in ipairs(items) do
        local line = vim.api.nvim_buf_get_lines(buf, rows[i], rows[i] + 1, false)[1]
        local entry = parse.parse_line(line)
        local original = entry and st.model.original_by_id[entry.id]
        local change = changes and changes[rows[i]]
        local duplicate_copy = change and change.op and change.op.type == "copy"
        if original and not duplicate_copy then
            table.insert(ops, {
                type = "delete",
                path = original.abs_path,
                kind = original.kind,
            })
        else
            table.insert(remove_rows, rows[i])
        end
    end
    table.sort(remove_rows, function(a, b)
        return a > b
    end)
    for _, row in ipairs(remove_rows) do
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, {})
    end

    plan.stage_ops(buf, ops)
    render.add_virtual_text(buf, st.root)
end

return M
