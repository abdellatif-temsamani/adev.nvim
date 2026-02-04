local M = {}

local NS = vim.api.nvim_create_namespace "adev-files"
local DISPLAY_NS = vim.api.nvim_create_namespace "adev_files_display"

local model = require "adev-files.core.model"

---@class AdevFilesState
---@field root string
---@field model AdevFilesModel
---@field view AdevFilesProjection|nil
---@field applying boolean
---@field pending_ops AdevFilesOp[]

---@type table<integer, AdevFilesState>
local states = {}

function M.ns()
    return NS
end

function M.display_ns()
    return DISPLAY_NS
end

---@param buf integer
---@param root string
---@return AdevFilesState
function M.init(buf, root)
    states[buf] = states[buf] or { root = root, model = model.new(root), view = nil, applying = false, pending_ops = {} }
    states[buf].root = root
    states[buf].model = model.new(root)
    states[buf].view = nil
    states[buf].applying = false
    states[buf].pending_ops = {}
    return states[buf]
end

---@param buf integer
---@return AdevFilesState|nil
function M.get(buf)
    return states[buf]
end

---@param buf integer
---@param next_model AdevFilesModel
function M.set_model(buf, next_model)
    if not states[buf] then
        return
    end
    states[buf].model = next_model
end

---@param buf integer
---@return AdevFilesModel|nil
function M.get_model(buf)
    local st = states[buf]
    if not st then
        return nil
    end
    return st.model
end

---@param buf integer
---@param view AdevFilesProjection|nil
function M.set_view(buf, view)
    if not states[buf] then
        return
    end
    states[buf].view = view
end

---@param buf integer
---@return AdevFilesProjection|nil
function M.get_view(buf)
    local st = states[buf]
    if not st then
        return nil
    end
    return st.view
end

---@param buf integer
---@return AdevFilesOp[]
function M.get_pending_ops(buf)
    local st = states[buf]
    if not st then
        return {}
    end
    return st.pending_ops or {}
end

---@param buf integer
---@param ops AdevFilesOp[]
function M.set_pending_ops(buf, ops)
    if not states[buf] then
        return
    end
    states[buf].pending_ops = ops or {}
end

---@param buf integer
function M.clear_pending_ops(buf)
    if not states[buf] then
        return
    end
    states[buf].pending_ops = {}
end

---@param buf integer
function M.clear(buf)
    states[buf] = nil
end

return M
