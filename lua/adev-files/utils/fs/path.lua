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

return M
