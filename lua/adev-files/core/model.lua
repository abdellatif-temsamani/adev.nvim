local root = require "adev-files.root"

local M = {}

---@class AdevFilesNodeSnapshot
---@field id integer
---@field fs_name string
---@field kind 'file'|'directory'
---@field abs_path string

---@class AdevFilesModel
---@field root string
---@field version integer
---@field original_by_id table<integer, AdevFilesNodeSnapshot>
---@field original_by_path table<string, integer>

---@param root_path string
---@return AdevFilesModel
function M.new(root_path)
    return {
        root = root.normalize_root(root_path),
        version = 0,
        original_by_id = {},
        original_by_path = {},
    }
end

---@param model AdevFilesModel
---@param entries { row: integer, entry: AdevFilesEntry, deleted: boolean }[]
---@param row_to_id table<integer, integer>
---@return AdevFilesModel
function M.snapshot(model, entries, row_to_id)
    model.original_by_id = {}
    model.original_by_path = {}
    for _, item in ipairs(entries) do
        if not item.deleted then
            local id = row_to_id[item.row]
            if id then
                local abs_path = model.root .. item.entry.fs_name
                model.original_by_id[id] = {
                    id = id,
                    fs_name = item.entry.fs_name,
                    kind = item.entry.kind,
                    abs_path = abs_path,
                }
                model.original_by_path[abs_path] = id
            end
        end
    end
    model.version = model.version + 1
    return model
end

---@class AdevFilesProjection
---@field current_by_id table<integer, { entry: AdevFilesEntry, abs_path: string, row: integer }>
---@field current_by_path table<string, integer>
---@field deleted_by_id table<integer, { entry: AdevFilesEntry, abs_path: string }>
---@field errors string[]

---@param model AdevFilesModel
---@param entries { row: integer, entry: AdevFilesEntry, deleted: boolean }[]
---@param row_to_id table<integer, integer>
---@return AdevFilesProjection
function M.project(model, entries, row_to_id)
    local current_by_id = {}
    local current_by_path = {}
    local deleted_by_id = {}
    local errors = {}

    for _, item in ipairs(entries) do
        local id = row_to_id[item.row]
        if id then
            local abs_path = model.root .. item.entry.fs_name
            if item.deleted then
                deleted_by_id[id] = { entry = item.entry, abs_path = abs_path }
            else
                if current_by_path[abs_path] and current_by_path[abs_path] ~= id then
                    table.insert(errors, "duplicate path: " .. item.entry.fs_name)
                end
                current_by_id[id] = { entry = item.entry, abs_path = abs_path, row = item.row }
                current_by_path[abs_path] = id
            end
        end
    end

    return {
        current_by_id = current_by_id,
        current_by_path = current_by_path,
        deleted_by_id = deleted_by_id,
        errors = errors,
    }
end

return M
