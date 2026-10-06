local parse = require "adev-files.parse.line"
local state = require "adev-files.state"

local M = {}
local next_id = 1

---@param buf integer
---@param row integer
---@return integer
function M.ensure_row(buf, row)
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
    local _, id = parse.strip_id(line)
    if not id then
        id = next_id
        next_id = next_id + 1
        vim.api.nvim_buf_set_text(buf, row, 0, row, 0, { string.format("/%d ", id) })
    end
    next_id = math.max(next_id, id + 1)
    vim.api.nvim_buf_set_extmark(buf, state.ns(), row, 0, { id = id })
    return id
end

---@param buf integer
---@param entries { row: integer, entry: AdevFilesEntry, deleted: boolean }[]
---@return table<integer, integer>, table<integer, integer>
function M.sync(buf, entries)
    M.clear(buf)
    local row_to_id = {}
    local id_to_row = {}
    for _, item in ipairs(entries) do
        -- Negative IDs only identify new, uncommitted rows in the projection.
        -- Existing and pasted entries carry their stable ID in the buffer.
        local id = item.entry.id or -(item.row + 1)
        row_to_id[item.row] = id
        if not id_to_row[id] then
            id_to_row[id] = item.row
            if id > 0 then
                vim.api.nvim_buf_set_extmark(buf, state.ns(), item.row, 0, { id = id })
            end
        end
    end

    return row_to_id, id_to_row
end

---@param buf integer
---@param node_id integer
---@return integer|nil
function M.row_for_node(buf, node_id)
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        local _, id = parse.strip_id(line)
        if id == node_id then
            return i - 1
        end
    end
    return nil
end

---@param buf integer
function M.clear(buf)
    vim.api.nvim_buf_clear_namespace(buf, state.ns(), 0, -1)
end

return M
