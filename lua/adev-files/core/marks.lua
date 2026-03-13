local state = require "adev-files.state"

local M = {}

---@param buf integer
---@param row integer
---@return integer
function M.ensure_row(buf, row)
    local ns = state.ns()
    local existing = vim.api.nvim_buf_get_extmarks(buf, ns, { row, 0 }, { row, -1 }, { limit = 1 })
    if #existing > 0 then
        return existing[1][1]
    end
    return vim.api.nvim_buf_set_extmark(buf, ns, row, 0, { right_gravity = false })
end

---@param buf integer
---@param entries { row: integer, entry: AdevFilesEntry, deleted: boolean }[]
---@return table<integer, integer>, table<integer, integer>
function M.sync(buf, entries)
    local ns = state.ns()
    local row_set = {}
    for _, item in ipairs(entries) do
        row_set[item.row] = true
    end

    local row_to_id = {}
    local id_to_row = {}
    local existing = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
    for _, mark in ipairs(existing) do
        local id = mark[1]
        local row = mark[2]
        if row_set[row] and not row_to_id[row] then
            row_to_id[row] = id
            id_to_row[id] = row
        else
            vim.api.nvim_buf_del_extmark(buf, ns, id)
        end
    end

    for _, item in ipairs(entries) do
        if not row_to_id[item.row] then
            local id = vim.api.nvim_buf_set_extmark(buf, ns, item.row, 0, {
                right_gravity = false,
            })
            row_to_id[item.row] = id
            id_to_row[id] = item.row
        end
    end

    return row_to_id, id_to_row
end

---@param buf integer
---@param node_id integer
---@return integer|nil
function M.row_for_node(buf, node_id)
    local pos = vim.api.nvim_buf_get_extmark_by_id(buf, state.ns(), node_id, {})
    if not pos or not pos[1] then
        return nil
    end
    return pos[1]
end

---@param buf integer
function M.clear(buf)
    vim.api.nvim_buf_clear_namespace(buf, state.ns(), 0, -1)
end

return M
