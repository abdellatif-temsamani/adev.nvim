local M = {}

local NS = vim.api.nvim_create_namespace "adev-files"

---@class AdevFilesMark
---@field kind 'file'|'directory'
---@field name string        -- display name (directories end with '/')
---@field fs_name string     -- filesystem name (no trailing '/')
---@field abs_path string

---@class AdevFilesState
---@field root string
---@field marks table<integer, AdevFilesMark>
---@field applying boolean

---@type table<integer, AdevFilesState>
local states = {}

function M.ns()
    return NS
end

---@param buf integer
---@param root string
---@return AdevFilesState
function M.init(buf, root)
    states[buf] = states[buf] or { root = root, marks = {}, applying = false }
    states[buf].root = root
    states[buf].marks = {}
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
function M.set_marks(buf, marks)
    if not states[buf] then
        return
    end
    states[buf].marks = marks
end

---@param buf integer
function M.clear(buf)
    states[buf] = nil
end

return M
