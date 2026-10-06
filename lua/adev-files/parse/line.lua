local trim = require "adev-files.parse.trim"
local validate = require "adev-files.parse.validate"

local M = {}

local DELETE_MARK = "  #del"

--- Entry IDs travel with the text, independently of row positions. They are
--- concealed by the renderer and resolved against the filesystem snapshot.
---@param line string
---@return string, integer?, integer
function M.strip_id(line)
    local id, name = (line or ""):match "^/(%d+) (.*)$"
    if id then
        return name, tonumber(id), #id + 2
    end
    return line or "", nil, 0
end

---@param line string
---@param id integer
---@return string
function M.with_id(line, id)
    local name = M.strip_id(line)
    return string.format("/%d %s", id, name)
end

---@param name string
---@return string
function M.format_name(name)
    if
        name:find '[\\"%c]'
        or name:match "^%s"
        or name:match "%s$"
        or vim.endswith(name, DELETE_MARK)
    then
        return vim.json.encode(name)
    end
    return name
end

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
---@field id? integer
---@field kind 'file'|'directory'
---@field name string     -- display name (directories end with '/')
---@field fs_name string  -- filesystem name (no trailing '/')
---@field display string

---@param line string
---@return AdevFilesEntry|nil, string|nil
function M.parse_line(line)
    line = M.strip_delete_marker(line)
    local id
    line, id = M.strip_id(line)
    if id and (id < 1 or id > 2147483647 or id % 1 ~= 0) then
        return nil, "invalid entry ID"
    end
    line = trim.trim(line or "")
    if line == "" then
        if id then
            return nil, "entry has no filename"
        end
        return nil, nil
    end

    local name = trim.trim(line)
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
    if fs_name:sub(1, 1) == '"' then
        local ok, decoded = pcall(vim.json.decode, fs_name)
        if not ok or type(decoded) ~= "string" then
            return nil, "invalid quoted filename"
        end
        fs_name = decoded
    end

    if not validate.is_valid_rel_path(fs_name) then
        return nil, "invalid path: '" .. fs_name .. "'"
    end

    return {
        id = id,
        kind = kind,
        name = name,
        fs_name = fs_name,
        display = name,
    },
        nil
end

return M
