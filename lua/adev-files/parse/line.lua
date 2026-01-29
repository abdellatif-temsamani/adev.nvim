local trim = require "adev-files.parse.trim"
local validate = require "adev-files.parse.validate"

local M = {}

---@class AdevFilesEntry
---@field kind 'file'|'directory'
---@field name string     -- display name (directories end with '/')
---@field fs_name string  -- filesystem name (no trailing '/')
---@field display string

---@param line string
---@return AdevFilesEntry|nil, string|nil
function M.parse_line(line)
    line = trim.trim(line or "")
    if line == "" then
        return nil, nil
    end

    -- Check for root: prefix (skip these lines)
    local prefix, rest = line:match "^(%a+)%s*:%s*(.*)$"
    if prefix == "root" then
        return nil, nil
    end

    local name = trim.trim(line)
    local stripped = name:match "^%S+%s+(.+)$"
    if stripped then
        local candidate = trim.trim(stripped)
        if candidate ~= "" then
            local candidate_fs = candidate
            if candidate:sub(-1) == "/" then
                candidate_fs = candidate:sub(1, -2)
            end
            if validate.is_valid_rel_path(candidate_fs) then
                name = candidate
            end
        end
    end
    if name == "" then
        return nil, nil
    end

    local kind
    if name:sub(-1) == "/" then
        kind = "directory"
    else
        kind = "file"
    end

    if kind == "directory" then
        if name:sub(-1) ~= "/" then
            name = name .. "/"
        end
    else
        if name:sub(-1) == "/" then
            return nil, "file entry cannot end with '/'"
        end
    end

    local fs_name = name
    if kind == "directory" then
        fs_name = name:sub(1, -2)
    end

    if not validate.is_valid_rel_path(fs_name) then
        return nil, "invalid path: '" .. fs_name .. "'"
    end

    return {
        kind = kind,
        name = name,
        fs_name = fs_name,
        display = name,
    },
        nil
end

return M
