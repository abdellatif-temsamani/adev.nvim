local path = require "adev-files.utils.fs.path"

local M = {}

---@class AdevFilesClipboardItem
---@field kind 'file'|'directory'
---@field src string

---@class AdevFilesClipboard
---@field mode 'copy'|'move'
---@field items AdevFilesClipboardItem[]

---@type AdevFilesClipboard|nil
local clip = nil

---@param mode 'copy'|'move'
---@param items AdevFilesClipboardItem[]
function M.set(mode, items)
    clip = {
        mode = mode,
        items = items,
    }
end

---@return AdevFilesClipboard|nil
function M.get()
    return clip
end

function M.clear()
    clip = nil
end

---@return boolean
function M.is_empty()
    return not clip or not clip.items or #clip.items == 0
end

---@param abs_path string
function M.remove_by_src(abs_path)
    if not clip then
        return
    end
    local kept = {}
    for _, item in ipairs(clip.items) do
        if path.abs(item.src) ~= abs_path then
            table.insert(kept, item)
        end
    end
    if #kept == 0 then
        clip = nil
    else
        clip.items = kept
    end
end

return M
