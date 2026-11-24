local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local selection = require "adev-files.events.selection"
local state = require "adev-files.state"
local utils = require "adev-common.utils"

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

    local pending = state.get_pending_ops(buf)
    local pending_destinations = {}
    for _, op in ipairs(pending) do
        if op.dst_id then
            pending_destinations[op.dst_id] = true
        end
    end

    local selected = {}
    for i, row in ipairs(rows) do
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
        local entry = parse.parse_line(line)
        selected[i] = { row = row, entry = entry }
    end

    -- A move owns its source. Removing the row would silently drop the move,
    -- so require the user to cancel it first.
    for _, item in ipairs(selected) do
        local original = item.entry and st.model.original_by_id[item.entry.id] or nil
        if original then
            for _, op in ipairs(pending) do
                if op.type == "move" and path.abs(op.src) == original.abs_path then
                    utils.err_notify(
                        "Cancel the pending move before deleting its source",
                        "adev-files"
                    )
                    return
                end
            end
        end
    end

    -- Deleting a pasted destination cancels the paste rather than leaving an
    -- invisible pending operation behind.
    local cancelled = {}
    for _, item in ipairs(selected) do
        local id = item.entry and item.entry.id or nil
        if id and pending_destinations[id] then
            cancelled[id] = true
        end
    end
    if next(cancelled) then
        local kept = {}
        for _, op in ipairs(pending) do
            if not (op.dst_id and cancelled[op.dst_id]) then
                table.insert(kept, op)
            end
        end
        state.set_pending_ops(buf, kept)
    end

    local ops = {}
    local remove_rows = {}
    local _, _, changes = plan.plan_ops(buf)
    for _, item in ipairs(selected) do
        local entry = item.entry
        local original = entry and st.model.original_by_id[entry.id] or nil
        local change = changes and changes[item.row]
        local duplicate_copy = change and change.op and change.op.type == "copy"
        local was_destination = entry and entry.id and cancelled[entry.id]

        if was_destination then
            table.insert(remove_rows, item.row)
        elseif original and not duplicate_copy then
            table.insert(ops, {
                type = "delete",
                path = original.abs_path,
                kind = original.kind,
            })
        else
            table.insert(remove_rows, item.row)
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
