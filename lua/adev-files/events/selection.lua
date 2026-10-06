local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@return integer[]
local function selected_rows(buf)
    local mode = vim.fn.mode()
    local rows = {}
    if mode == "v" or mode == "V" or mode == "\22" then
        -- The active selection anchor is independent of the previous '< / '>.
        local first = vim.fn.getpos("v")[2]
        local last = vim.api.nvim_win_get_cursor(0)[1]
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
            table.insert(rows, vim.api.nvim_win_get_cursor(0)[1] - 1)
        end
    end
    table.sort(rows)
    return rows
end

local function collect(buf, existing_only)
    local st = state.get(buf)
    if not st then
        return {}, {}, 0
    end
    local renamed = {}
    if existing_only then
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
                    return {}, {}, 0, "Save or revert the pending rename before copying or cutting"
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
---@return AdevFilesClipboardItem[], integer, string?
function M.collect_entries(buf)
    local items, _, skipped, err = collect(buf, true)
    return items, skipped, err
end

---@param buf integer
---@return AdevFilesClipboardItem[], integer[]
function M.collect_entries_with_rows(buf)
    return collect(buf, false)
end

---@param buf integer
function M.toggle_mark(buf)
    local st = state.get(buf)
    if not st or st.applying or st.confirming then
        return
    end
    local row = vim.api.nvim_win_get_cursor(0)[1] - 1
    local entry = parse.parse_line(vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1])
    if not entry or not entry.id then
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
