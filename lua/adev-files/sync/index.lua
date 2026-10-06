local marks = require "adev-files.core.marks"
local model = require "adev-files.core.model"
local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"
local state = require "adev-files.state"
local view = require "adev-files.core.view"

local M = {}

--- Restore a concealed ID removed by a whole-line edit. The ID is captured
--- from the edit event before replacement, rather than inferred from a row.
---@param buf integer
function M.restore_ids(buf)
    local st = state.get(buf)
    if not st or st.confirming or st.applying then
        return
    end
    local missing = st.missing_ids or {}
    st.missing_ids = {}
    for row, id in pairs(missing) do
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
        if line then
            local _, current_id = parse.strip_id(line)
            if not current_id then
                vim.api.nvim_buf_set_text(buf, row, 0, row, 0, { string.format("/%d ", id) })
            end
        end
    end
    -- Recover unchanged names when a bulk edit removed their concealed IDs.
    -- This prevents an unchanged file from becoming a delete/create pair.
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        if i > 1 then
            local entry = parse.parse_line(line)
            if entry and not entry.id then
                local abs = path.join_abs(st.root, entry.fs_name)
                local id = st.model.original_by_path[abs]
                if id then
                    vim.api.nvim_buf_set_text(
                        buf,
                        i - 1,
                        0,
                        i - 1,
                        0,
                        { string.format("/%d ", id) }
                    )
                end
            end
        end
    end
end

---@param buf integer
---@return boolean, string?
function M.index_original(buf)
    local st = state.get(buf)
    if not st then
        return false, "missing state"
    end
    st.missing_ids = {}

    marks.clear(buf)
    local entries, err = view.parse_buffer(buf)
    if err then
        return false, err
    end
    for _, item in ipairs(entries) do
        item.entry.id = marks.ensure_row(buf, item.row)
    end
    local row_to_id = marks.sync(buf, entries)

    local original_lines = {}
    for _, item in ipairs(entries) do
        original_lines[item.row] = {
            entry = vim.deepcopy(item.entry),
            abs_path = path.join_abs(st.root, item.entry.fs_name),
        }
    end
    state.set_original_lines(buf, original_lines)

    local next_model = model.new(st.root)
    model.snapshot(next_model, entries, row_to_id)
    state.set_model(buf, next_model)
    state.set_view(buf, model.project(next_model, entries, row_to_id))
    vim.bo[buf].modified = false
    return true
end

---@param buf integer
---@return boolean, string?
function M.reindex(buf)
    local st = state.get(buf)
    if not st then
        return false, "missing state"
    end

    local entries, err = view.parse_buffer(buf)
    if err then
        return false, err
    end
    local row_to_id = marks.sync(buf, entries)
    local current_model = st.model or model.new(st.root)
    state.set_view(buf, model.project(current_model, entries, row_to_id))
    return true
end

return M
