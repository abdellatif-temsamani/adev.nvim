local state = require "adev-files.state"
local view = require "adev-files.core.view"
local marks = require "adev-files.core.marks"
local model = require "adev-files.core.model"
local planner = require "adev-files.core.planner"

local M = {}

---@param op AdevFilesOp
---@return string
local function op_key(op)
    if op.type == "delete" or op.type == "create" then
        return string.format("%s:%s", op.type, op.path or "")
    end
    if op.type == "rename" or op.type == "copy" or op.type == "move" then
        return string.format("%s:%s->%s:%s", op.type, op.src or "", op.dst or "", op.dst_id or "")
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

---@param buf integer
---@return AdevFilesOp[]|nil, string|nil
function M.plan_ops(buf)
    local st = state.get(buf)
    if not st then
        return nil, "missing state"
    end

    local entries, err = view.parse_buffer(buf)
    if err then
        return nil, err
    end

    local row_to_id = marks.sync(buf, entries)
    local current_model = st.model or model.new(st.root)
    local projection = model.project(current_model, entries, row_to_id)
    state.set_view(buf, projection)

    local ops, plan_err, updated_pending = planner.plan(current_model, projection, state.get_pending_ops(buf))
    if plan_err then
        return nil, plan_err
    end
    if updated_pending then
        state.set_pending_ops(buf, updated_pending)
    end

    return ops, nil
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
