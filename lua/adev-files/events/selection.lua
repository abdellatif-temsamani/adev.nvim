local parse = require "adev-files.parse"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@return AdevFilesClipboardItem[], integer
function M.collect_entries(buf)
    local st = state.get(buf)
    if not st then
        return {}, 0
    end

    local mode = vim.fn.mode()
    local items = {}
    local skipped = 0

    local function abs_path(root, fs_name)
        return vim.fn.fnamemodify(root .. fs_name, ":p")
    end

    local function exists_in_snapshot(entry)
        if not st.model or not st.model.original_by_path then
            return false
        end
        local root = st.model.root or st.root
        return st.model.original_by_path[root .. entry.fs_name] ~= nil
    end

    local push = function(line)
        local entry, err = parse.parse_line(line)
        if err or not entry then
            return
        end
        if entry.kind ~= "file" and entry.kind ~= "directory" then
            return
        end
        if not exists_in_snapshot(entry) then
            skipped = skipped + 1
            return
        end
        table.insert(items, { kind = entry.kind, src = abs_path(st.root, entry.fs_name) })
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

    return items, skipped
end

---@param buf integer
---@return AdevFilesClipboardItem[], integer[]
function M.collect_entries_with_rows(buf)
    local st = state.get(buf)
    if not st then
        return {}, {}
    end

    local mode = vim.fn.mode()
    local items = {}
    local rows = {}

    local function abs_path(root, fs_name)
        return vim.fn.fnamemodify(root .. fs_name, ":p")
    end

    local push = function(line, row)
        local entry, err = parse.parse_line(line)
        if err or not entry then
            return
        end
        if entry.kind ~= "file" and entry.kind ~= "directory" then
            return
        end
        table.insert(items, { kind = entry.kind, src = abs_path(st.root, entry.fs_name) })
        table.insert(rows, row)
    end

    if mode == "v" or mode == "V" or mode == "\22" then
        local a = vim.fn.getpos("'<")[2]
        local b = vim.fn.getpos("'>")[2]
        if a > b then
            a, b = b, a
        end
        vim.cmd "normal! \\<Esc>"
        local lines = vim.api.nvim_buf_get_lines(buf, a - 1, b, false)
        for i, l in ipairs(lines) do
            push(l, (a - 1) + (i - 1))
        end
    else
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        push(vim.api.nvim_get_current_line(), row)
    end

    return items, rows
end

return M
