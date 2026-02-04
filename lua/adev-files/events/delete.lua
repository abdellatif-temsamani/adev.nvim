local state = require "adev-files.state"
local selection = require "adev-files.events.selection"
local parse = require "adev-files.parse"

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

    local seen = {}
    for _, row in ipairs(rows) do
        if not seen[row] then
            local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
            local marked = parse.mark_delete(line)
            vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { marked })
            seen[row] = true
        end
    end
end

return M
