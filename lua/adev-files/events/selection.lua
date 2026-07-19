local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"
local render = require "adev-files.file_manager.render"
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
        return path.join_abs(root, fs_name)
    end

    local function exists_in_snapshot(entry)
        local original_lines = state.get_original_lines(buf)
        for _, orig in pairs(original_lines) do
            if orig.entry.fs_name == entry.fs_name then
                return true
            end
        end
        return false
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
        if a == 0 or b == 0 then
            -- Marks not set; fall back to current line
            push(vim.api.nvim_get_current_line())
        else
            if a > b then
                a, b = b, a
            end
            vim.cmd "normal! \\<Esc>"
            local lines = vim.api.nvim_buf_get_lines(buf, a - 1, b, false)
            for _, l in ipairs(lines) do
                push(l)
            end
        end
    else
        local marks = state.get_selection_marks(buf)
        if next(marks) then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            for row, _ in pairs(marks) do
                if row >= 0 and row < #lines then
                    push(lines[row + 1])
                end
            end
        else
            push(vim.api.nvim_get_current_line())
        end
    end

    return items, skipped
end

---@param buf integer
function M.toggle_mark(buf)
    local st = state.get(buf)
    if not st then
        return
    end
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local marks = state.get_selection_marks(buf)
    if marks[row] then
        marks[row] = nil
    else
        marks[row] = true
    end
    state.set_selection_marks(buf, marks)
    render.add_virtual_text(buf, st.root)
end

---@param buf integer
function M.clear_marks(buf)
    local st = state.get(buf)
    if not st then
        return
    end
    state.clear_selection_marks(buf)
    render.add_virtual_text(buf, st.root)
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
        return path.join_abs(root, fs_name)
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
        if a == 0 or b == 0 then
            -- Marks not set; fall back to current line
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            push(vim.api.nvim_get_current_line(), row)
        else
            if a > b then
                a, b = b, a
            end
            vim.cmd "normal! \\<Esc>"
            local lines = vim.api.nvim_buf_get_lines(buf, a - 1, b, false)
            for i, l in ipairs(lines) do
                push(l, (a - 1) + (i - 1))
            end
        end
    else
        local marks = state.get_selection_marks(buf)
        if next(marks) then
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            for row, _ in pairs(marks) do
                if row >= 0 and row < #lines then
                    push(lines[row + 1], row)
                end
            end
        else
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            push(vim.api.nvim_get_current_line(), row)
        end
    end

    return items, rows
end

return M
