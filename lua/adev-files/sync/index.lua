local state = require "adev-files.state"
local model = require "adev-files.core.model"
local marks = require "adev-files.core.marks"
local view = require "adev-files.core.view"

local M = {}

---@param buf integer
---@return boolean, string?
function M.index_original(buf)
    local st = state.get(buf)
    if not st then
        return false, "missing state"
    end

    marks.clear(buf)
    local entries, err = view.parse_buffer(buf)
    if err then
        return false, err
    end
    local row_to_id = marks.sync(buf, entries)

    local next_model = model.new(st.root)
    model.snapshot(next_model, entries, row_to_id)
    state.set_model(buf, next_model)
    state.set_view(buf, model.project(next_model, entries, row_to_id))
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
