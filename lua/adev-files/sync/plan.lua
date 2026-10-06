local index = require "adev-files.sync.index"
local planner = require "adev-files.core.planner"
local state = require "adev-files.state"
local view = require "adev-files.core.view"

local M = {}

---@param op AdevFilesOp
---@return string
local function op_key(op)
    if op.type == "delete" or op.type == "create" then
        return string.format("%s:%s", op.type, op.path or "")
    end
    if op.type == "rename" or op.type == "copy" or op.type == "move" then
        return string.format("%s:%s->%s", op.type, op.src or "", op.dst or "")
    end
    return "unknown"
end

---@class AdevFilesOp
---@field type 'create'|'delete'|'rename'|'copy'|'move'
---@field kind? 'file'|'directory'
---@field path? string
---@field src? string
---@field dst? string
---@field dst_id? integer
---@field row? integer

---@param buf integer
---@return AdevFilesOp[]|nil, string|nil, table<integer, AdevFilesRowChange>?
function M.plan_ops(buf)
    local st = state.get(buf)
    if not st then
        return nil, "missing state"
    end
    if st.needs_refresh then
        return nil, "Changes were saved; refresh the directory before editing again"
    end
    index.restore_ids(buf)
    local entries, err = view.parse_buffer(buf)
    if err then
        st.plan_error = err
        st.change_ops = nil
        st.row_changes = {}
        return nil, err
    end
    index.reindex(buf)
    local ops, plan_err, updated_pending, changes =
        planner.plan(st.model, entries, state.get_pending_ops(buf))
    st.plan_error = plan_err
    st.change_ops = ops
    st.row_changes = changes or {}
    if plan_err then
        return nil, plan_err
    end
    if updated_pending then
        state.set_pending_ops(buf, updated_pending)
    end

    return ops, nil, changes
end

---@param buf integer
---@param ops AdevFilesOp[]
function M.stage_ops(buf, ops)
    local st = state.get(buf)
    if not st or not ops or #ops == 0 then
        return
    end

    local pending = state.get_pending_ops(buf)
    local new_keys = {}
    for _, op in ipairs(ops) do
        new_keys[op_key(op)] = true
    end

    local merged = {}
    for _, op in ipairs(pending) do
        if not new_keys[op_key(op)] then
            table.insert(merged, op)
        end
    end
    for _, op in ipairs(ops) do
        table.insert(merged, op)
    end

    state.set_pending_ops(buf, merged)
    if vim.api.nvim_buf_is_valid(buf) then
        vim.bo[buf].modified = true
    end
end

return M
