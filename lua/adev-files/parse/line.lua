local trim = require "adev-files.parse.trim"
local validate = require "adev-files.parse.validate"

local M = {}

local DELETE_MARK = "  #del"

---@param line string
---@return string, boolean
function M.strip_delete_marker(line)
    if not line or line == "" then
        return line or "", false
    end
    if #line >= #DELETE_MARK and line:sub(-#DELETE_MARK) == DELETE_MARK then
        return line:sub(1, -#DELETE_MARK - 1), true
    end
    return line, false
end

---@param line string
---@return string, boolean
function M.toggle_delete_marker(line)
    local stripped, marked = M.strip_delete_marker(line)
    if marked then
        return stripped, false
    end
    local trimmed = trim.trim(stripped or "")
    if trimmed == "" then
        return line or "", false
    end
    return trimmed .. DELETE_MARK, true
end

---@param line string
---@return string
function M.mark_delete(line)
    local stripped, marked = M.strip_delete_marker(line)
    if marked then
        return stripped .. DELETE_MARK
    end
    local trimmed = trim.trim(stripped or "")
    if trimmed == "" then
        return line or ""
    end
    return trimmed .. DELETE_MARK
end

---@class AdevFilesEntry
---@field kind 'file'|'directory'
---@field name string     -- display name (directories end with '/')
---@field fs_name string  -- filesystem name (no trailing '/')
---@field display string

---@param line string
---@return AdevFilesEntry|nil, string|nil
function M.parse_line(line)
    line = M.strip_delete_marker(line)
    line = trim.trim(line or "")
    if line == "" then
        return nil, nil
    end

    if line:sub(1, 1) == "[" and line:sub(-1) == "]" then
        return nil, nil
    end
    if line:match "^=+$" then
        return nil, nil
    end

    -- Check for root: prefix (skip these lines)
    local prefix, rest = line:match "^(%a+)%s*:%s*(.*)$"
    if prefix == "root" then
        return nil, nil
    end

    local name = trim.trim(line)

    local function is_icon_prefix(prefix)
        return prefix:find("[%w%._%-]") == nil
    end

    local prefix, rest = name:match "^(%S+)%s+(.+)$"
    if prefix and rest and is_icon_prefix(prefix) then
        local candidate = trim.trim(rest)
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
