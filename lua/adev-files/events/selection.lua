local utils = require "adev-common.utils"

local index = require "adev-files.sync.index"
local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@return integer|nil
local function cursor_row(buf)
    local current = vim.api.nvim_get_current_win()
    local win = vim.api.nvim_win_get_buf(current) == buf and current or vim.fn.bufwinid(buf)
    if win == -1 then
        return nil
    end
    return vim.api.nvim_win_get_cursor(win)[1]
end

---@param buf integer
---@return integer[]
local function selected_rows(buf)
    local mode = vim.fn.mode()
    local rows = {}
    if mode == "v" or mode == "V" or mode == "\22" then
        -- The active selection anchor is independent of the previous '< / '>.
        local first = vim.fn.getpos("v")[2]
        local last = cursor_row(buf) or first
        if first > last then
            first, last = last, first
        end
        for row = first - 1, last - 1 do
            table.insert(rows, row)
        end
        vim.cmd("normal! " .. string.char(27))
    else
        for row in pairs(state.get_selection_marks(buf)) do
            table.insert(rows, row)
        end
        if #rows == 0 then
            local current = cursor_row(buf)
            if current then
                table.insert(rows, current - 1)
            end
        end
    end
    table.sort(rows)
    return rows
end

local function collect(buf, existing_only, mode)
    local st = state.get(buf)
    if not st then
        return {}, {}, 0
    end
    -- A whole-line edit can temporarily remove the concealed ID. Recover it
    -- before resolving originals so copy/cut actions see the correct identity.
    index.restore_ids(buf)
    local renamed = {}
    if existing_only and mode ~= "copy" then
        local ops, err = plan.plan_ops(buf)
        if not ops then
            return {}, {}, 0, err
        end
        for _, op in ipairs(ops) do
            if op.type == "rename" then
                renamed[op.src] = true
            end
        end
    end
    local items, rows, skipped = {}, {}, 0
    local seen = {}
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for _, row in ipairs(selected_rows(buf)) do
        if row >= 1 then
            local line = lines[row + 1] or ""
            local _, deleted = parse.strip_delete_marker(line)
            local entry = parse.parse_line(line)
            if entry and not deleted then
                local original = st.model.original_by_id[entry.id]
                if existing_only and original and renamed[original.abs_path] then
                    return {}, {}, 0, "Save or revert the pending rename before cutting this entry"
                end
                if existing_only and not original then
                    skipped = skipped + 1
                else
                    local src = original and original.abs_path
                        or path.join_abs(st.root, entry.fs_name)
                    if not seen[src] then
                        seen[src] = true
                        table.insert(
                            items,
                            { src = src, kind = original and original.kind or entry.kind }
                        )
                        table.insert(rows, row)
                    end
                end
            end
        end
    end
    return items, rows, skipped
end

---@param buf integer
---@param mode? 'copy'|'move'
---@return AdevFilesClipboardItem[], integer, string?
function M.collect_entries(buf, mode)
    local items, _, skipped, err = collect(buf, true, mode)
    return items, skipped, err
end

---@param buf integer
---@return AdevFilesClipboardItem[], integer[], integer?, string?
function M.collect_entries_with_rows(buf)
    return collect(buf, false)
end

---@param buf integer
function M.toggle_mark(buf)
    local st = state.get(buf)
    if not st or st.applying or st.confirming then
        return
    end
    local current = cursor_row(buf)
    if not current then
        return
    end
    local row = current - 1
    if row < 1 then
        utils.notify("Cannot mark the header row", vim.log.levels.INFO, "adev-files")
        return
    end
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
    local entry = parse.parse_line(line)
    if not entry or not entry.id then
        utils.notify("Cannot mark this row", vim.log.levels.INFO, "adev-files")
        return
    end
    local selected = state.get_selection_marks(buf)
    selected[row] = not selected[row] or nil
    state.set_selection_marks(buf, selected)
    render.add_virtual_text(buf, st.root)
end

---@param buf integer
function M.clear_marks(buf)
    local st = state.get(buf)
    if st then
        state.clear_selection_marks(buf)
        render.add_virtual_text(buf, st.root)
    end
end

return M
