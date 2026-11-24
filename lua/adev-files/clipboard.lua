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

---@param base string
---@param child string
---@return boolean
local function is_under(base, child)
    if base == "/" then
        return child:sub(1, 1) == "/"
    end
    return child == base or child:sub(1, #base + 1) == base .. "/"
end

--- Keep clipboard entries usable after paths move or disappear.
---@param ops AdevFilesOp[]
function M.apply_path_changes(ops)
    if not clip or not clip.items then
        return
    end

    local deleted = {}
    local relocations = {}
    for _, op in ipairs(ops or {}) do
        if op.type == "delete" and op.path then
            table.insert(deleted, path.abs(op.path))
        elseif (op.type == "rename" or op.type == "move") and op.src and op.dst then
            table.insert(relocations, { src = path.abs(op.src), dst = path.abs(op.dst) })
        end
    end

    local kept = {}
    local seen = {}
    for _, item in ipairs(clip.items) do
        local src = path.abs(item.src)
        local removed = false
        for _, deleted_path in ipairs(deleted) do
            if is_under(deleted_path, src) then
                removed = true
                break
            end
        end

        if not removed then
            -- A plan can contain chained relocations (/a -> /b -> /c). Follow
            -- them until the path settles; `visited` breaks malformed cycles.
            local visited = {}
            while not visited[src] do
                visited[src] = true
                local matched = nil
                for _, relocation in ipairs(relocations) do
                    if
                        is_under(relocation.src, src)
                        and (not matched or #relocation.src > #matched.src)
                    then
                        matched = relocation
                    end
                end
                if not matched then
                    break
                end
                local next_src = matched.dst .. src:sub(#matched.src + 1)
                if visited[next_src] then
                    break
                end
                src = next_src
            end

            if not seen[src] then
                seen[src] = true
                local remapped = vim.deepcopy(item)
                remapped.src = src
                table.insert(kept, remapped)
            end
        end
    end

    if #kept == 0 then
        clip = nil
    else
        clip.items = kept
    end
end

return M
