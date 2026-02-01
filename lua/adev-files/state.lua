local M = {}

local NS = vim.api.nvim_create_namespace "adev-files"
local LIVE_NS = vim.api.nvim_create_namespace "adev_files_live"
local DISPLAY_NS = vim.api.nvim_create_namespace "adev_files_display"

---@class AdevFilesMark
---@field kind 'file'|'directory'
---@field name string        -- display name (directories end with '/')
---@field fs_name string     -- filesystem name (no trailing '/')
---@field abs_path string

---@class AdevFilesState
---@field root string
---@field original_marks table<integer, AdevFilesMark>
---@field live_marks table<integer, AdevFilesMark>
---@field applying boolean

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
    states[buf] = states[buf] or { root = root, original_marks = {}, live_marks = {}, applying = false }
    states[buf].root = root
    states[buf].original_marks = {}
    states[buf].live_marks = {}
    states[buf].applying = false
    return states[buf]
end

---@param buf integer
---@return AdevFilesState|nil
function M.get(buf)
    return states[buf]
end

---@param buf integer
---@param marks table<integer, AdevFilesMark>
function M.set_original_marks(buf, marks)
    if not states[buf] then
        return
    end
    states[buf].original_marks = marks
end

---@param buf integer
---@param marks table<integer, AdevFilesMark>
function M.set_live_marks(buf, marks)
    if not states[buf] then
        return
    end
    states[buf].live_marks = marks
end

---@param buf integer
function M.clear(buf)
    states[buf] = nil
end

return M
