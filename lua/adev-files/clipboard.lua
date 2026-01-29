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

return M
