local uv = require "adev-files.utils.fs.uv"

local M = {}

---@param path string
---@return string
function M.norm_real(path)
    local rp = uv.fs_realpath(path)
    if not rp or rp == "" then
        return path
    end
    return rp
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

---@param root string
---@param path string
---@return string
function M.relpath(root, path)
    if not path or path == "" then
        return path
    end

    local function normalize_abs(value)
        local abs = vim.fn.fnamemodify(value, ":p")
        if abs:sub(-1) == "/" and #abs > 1 then
            abs = abs:sub(1, -2)
        end
        return abs
    end

    local root_abs = normalize_abs(root)
    local path_abs = normalize_abs(path)

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
