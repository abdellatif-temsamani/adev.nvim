local state = require "adev-files.state"
local sync = require "adev-files.sync"

local selection = require "adev-files.events.selection"

local M = {}

---@param buf integer
function M.delete_selected(buf)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end

    local items = selection.collect_entries(buf)
    if #items == 0 then
        return
    end

    local ops = {}
    for _, item in ipairs(items) do
        local path = item.src
        if item.kind == "directory" and path:sub(-1) == "/" then
            path = path:sub(1, -2)
        end
        table.insert(ops, { type = "delete", kind = item.kind, path = path })
    end

    local opts = { title = "adev-files" }
    if vim.bo[buf].modified then
        opts.preface = { "Note: the view has unsaved edits; confirming will discard them." }
    end
    sync.apply_ops_with_confirm(buf, ops, opts)
end

return M
