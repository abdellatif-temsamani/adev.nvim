local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local selection = require "adev-files.events.selection"
local state = require "adev-files.state"

local M = {}

---@param buf integer
function M.delete_selected(buf)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end

    local items, rows = selection.collect_entries_with_rows(buf)
    if #items == 0 or #rows == 0 then
        return
    end

    local ops = {}
    for _, item in ipairs(items) do
        table.insert(ops, {
            type = "delete",
            path = item.src,
            kind = item.kind,
        })
    end

    if #ops == 0 then
        return
    end

    plan.stage_ops(buf, ops)
    render.add_virtual_text(buf, st.root)
end

return M
