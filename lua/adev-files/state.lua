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
---@field confirming boolean
---@field pending_ops AdevFilesOp[]
---@field original_lines table<integer, {entry: AdevFilesEntry, abs_path: string}>
---@field show_hidden boolean
---@field selection_marks table<integer, true>
---@field git_status table<string, string>|nil  -- rel_path -> status char
---@field git_files table<string, string>|nil
---@field git_generation integer
---@field change_ops AdevFilesOp[]|nil
---@field row_changes table<integer, AdevFilesRowChange>
---@field plan_error string|nil
---@field needs_refresh boolean
---@field refresh_modifiable? boolean

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
            confirming = false,
            pending_ops = {},
            original_lines = {},
            show_hidden = false,
            selection_marks = {},
            selection_ids = {},
            git_status = nil,
            git_files = nil,
            git_generation = 0,
            change_ops = nil,
            row_changes = {},
        }
    states[buf].root = root
    states[buf].model = model.new(root)
    states[buf].view = nil
    states[buf].applying = false
    states[buf].confirming = false
    states[buf].pending_ops = {}
    states[buf].original_lines = {}
    states[buf].show_hidden = false
    states[buf].selection_marks = {}
    states[buf].selection_ids = {}
    states[buf].git_status = nil
    states[buf].git_files = nil
    states[buf].git_generation = (states[buf].git_generation or 0) + 1
    states[buf].change_ops = nil
    states[buf].row_changes = {}
    states[buf].plan_error = nil
    states[buf].needs_refresh = false
    states[buf].refresh_modifiable = nil
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
    local rows = {}
    if st and vim.api.nvim_buf_is_valid(buf) then
        local parse = require "adev-files.parse"
        for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
            local _, id = parse.strip_id(line)
            if id and st.selection_ids[id] then
                rows[i - 1] = true
            end
        end
    end
    return rows
end

---@param buf integer
---@param marks table<integer, true>
function M.set_selection_marks(buf, marks)
    if not states[buf] then
        return
    end
    states[buf].selection_marks = marks or {}
    states[buf].selection_ids = {}
    local parse = require "adev-files.parse"
    for row in pairs(marks or {}) do
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
        local _, id = parse.strip_id(line)
        if id then
            states[buf].selection_ids[id] = true
        end
    end
end

---@param buf integer
function M.clear_selection_marks(buf)
    if not states[buf] then
        return
    end
    states[buf].selection_marks = {}
    states[buf].selection_ids = {}
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
function M.set_git_status(buf, status, files)
    if not states[buf] then
        return
    end
    states[buf].git_status = status
    states[buf].git_files = files
end

---@param buf integer
function M.clear(buf)
    states[buf] = nil
end

return M
