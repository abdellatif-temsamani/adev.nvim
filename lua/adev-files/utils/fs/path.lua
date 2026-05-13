local uv = require "adev-files.utils.fs.uv"

local M = {}

---@param path string
---@return string
function M.abs(path)
    local abs = vim.fn.fnamemodify(path, ":p")
    if abs:sub(-1) == "/" and #abs > 1 then
        abs = abs:sub(1, -2)
    end
    return abs
end

---@param base string
---@param rel string
---@return string
function M.join_abs(base, rel)
    base = base or ""
    rel = rel or ""
    if base ~= "" and rel ~= "" and base:sub(-1) ~= "/" then
        base = base .. "/"
    end
    return M.abs(base .. rel)
end

---@param path string
---@return string
function M.norm_real(path)
    local rp = uv.fs_realpath(path)
    if not rp or rp == "" then
        return M.abs(path)
    end
    return M.abs(rp)
end

---@param base string
---@param child string
---@return boolean
function M.is_subpath(base, child)
    base = M.norm_real(base)
    child = M.norm_real(child)

    if base:sub(-1) ~= "/" then
        base = base .. "/"
    end
    return child:sub(1, #base) == base
end

---@param base string
---@param child string
---@return boolean
function M.is_same_or_subpath(base, child)
    base = M.norm_real(base)
    child = M.norm_real(child)

    return base == child or M.is_subpath(base, child)
end

---@param root string
---@param path string
---@return string
function M.relpath(root, path)
    if not path or path == "" then
        return path
    end

    local root_abs = M.abs(root)
    local path_abs = M.abs(path)

    if vim.fs and vim.fs.relpath then
        local rel = vim.fs.relpath(path_abs, root_abs)
        if rel and rel ~= "" then
            return rel
        end
    end

    local root_parts = vim.split(root_abs, "/", { plain = true, trimempty = true })
    local path_parts = vim.split(path_abs, "/", { plain = true, trimempty = true })

    local idx = 1
    while idx <= #root_parts and idx <= #path_parts and root_parts[idx] == path_parts[idx] do
        idx = idx + 1
    end

    local rel_parts = {}
    for _ = idx, #root_parts do
        table.insert(rel_parts, "..")
    end
    for i = idx, #path_parts do
        table.insert(rel_parts, path_parts[i])
    end

    if #rel_parts == 0 then
        return "."
    end
    return table.concat(rel_parts, "/")
end

return M
