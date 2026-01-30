local parse = require "adev-files.parse"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@return AdevFilesClipboardItem[]
function M.collect_entries(buf)
    local st = state.get(buf)
    if not st then
        return {}
    end

    local mode = vim.fn.mode()
    local items = {}

    local push = function(line)
        local entry, err = parse.parse_line(line)
        if err or not entry then
            return
        end
        if entry.kind ~= "file" and entry.kind ~= "directory" then
            return
        end
        table.insert(items, { kind = entry.kind, src = st.root .. entry.fs_name })
    end

    if mode == "v" or mode == "V" or mode == "\22" then
        local a = vim.fn.getpos("'<")[2]
        local b = vim.fn.getpos("'>")[2]
        if a > b then
            a, b = b, a
        end
        vim.cmd "normal! \\<Esc>"
        local lines = vim.api.nvim_buf_get_lines(buf, a - 1, b, false)
        for _, l in ipairs(lines) do
            push(l)
        end
    else
        push(vim.api.nvim_get_current_line())
    end

    return items
end

return M
