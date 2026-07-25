local M = {}

local NS = vim.api.nvim_create_namespace "adev-files"
local LIVE_NS = vim.api.nvim_create_namespace "adev_files_live"
local DISPLAY_NS = vim.api.nvim_create_namespace "adev_files_display"

local model = require "adev-files.core.model"

---@class AdevFilesState
---@field root string
---@field initial_root string
---@field model AdevFilesModel
---@field view AdevFilesProjection|nil
---@field applying boolean
---@field pending_ops AdevFilesOp[]
---@field original_lines table<integer, {entry: AdevFilesEntry, abs_path: string}>
---@field show_hidden boolean
---@field selection_marks table<integer, true>
---@field git_status table<string, string>|nil  -- rel_path -> status char

---@type table<integer, AdevFilesState>
local states = {}

function M.ns()
    return NS
end

function M.display_ns()
    return DISPLAY_NS
end

function M.live_ns()
    return LIVE_NS
end

---@param buf integer
---@param root string
---@return AdevFilesState
function M.init(buf, root)
    states[buf] = states[buf]
        or {
            root = root,
            initial_root = root,
            model = model.new(root),
            view = nil,
            applying = false,
            pending_ops = {},
            original_lines = {},
            show_hidden = false,
            selection_marks = {},
            git_status = nil,
        }
    states[buf].root = root
    states[buf].model = model.new(root)
    states[buf].view = nil
    states[buf].applying = false
    states[buf].pending_ops = {}
    states[buf].original_lines = {}
    states[buf].show_hidden = false
    states[buf].selection_marks = {}
    states[buf].git_status = nil
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
---@param lines table<integer, {entry: AdevFilesEntry, abs_path: string}>
function M.set_original_lines(buf, lines)
    if not states[buf] then
        return
    end
    states[buf].original_lines = lines or {}
end

---@param buf integer
---@return table<integer, {entry: AdevFilesEntry, abs_path: string}>
function M.get_original_lines(buf)
    local st = states[buf]
    if not st then
        return {}
    end
    return st.original_lines or {}
end

---@param buf integer
---@return boolean
function M.get_show_hidden(buf)
    local st = states[buf]
    if not st then
        return false
    end
    return st.show_hidden or false
end

---@param buf integer
---@param val boolean
function M.set_show_hidden(buf, val)
    if not states[buf] then
        return
    end
    states[buf].show_hidden = val
end

---@param buf integer
---@return table<integer, true>
function M.get_selection_marks(buf)
    local st = states[buf]
    return st and st.selection_marks or {}
end

---@param buf integer
---@param marks table<integer, true>
function M.set_selection_marks(buf, marks)
    if not states[buf] then
        return
    end
    states[buf].selection_marks = marks or {}
end

---@param buf integer
function M.clear_selection_marks(buf)
    if not states[buf] then
        return
    end
    states[buf].selection_marks = {}
end

---@param buf integer
---@return table<string, string>|nil
function M.get_git_status(buf)
    local st = states[buf]
    if not st then
        return nil
    end
    return st.git_status
end

---@param buf integer
---@param status table<string, string>
function M.set_git_status(buf, status)
    if not states[buf] then
        return
    end
    states[buf].git_status = status
end

---@param buf integer
function M.clear(buf)
    states[buf] = nil
end

return M
