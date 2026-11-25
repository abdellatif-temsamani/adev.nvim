local path = require "adev-files.utils.fs.path"
local stat = require "adev-files.utils.fs.stat"
local uv = require "adev-files.utils.fs.uv"

local M = {}

---@param target string
---@return boolean
local function is_absolute(target)
    return target:sub(1, 1) == "/" or target:match "^%a:[\\/]" ~= nil
end

---@param base string
---@param candidate string
---@return boolean
local function is_within(base, candidate)
    base = path.abs(base)
    candidate = path.abs(candidate)
    if base:sub(-1) ~= "/" then
        base = base .. "/"
    end
    return candidate == base:sub(1, -2) or candidate:sub(1, #base) == base
end

---@param src string
---@param dst string
---@param target string
---@param opts? {move?: boolean, source_root?: string, original_root?: string, dest_root?: string}
---@return string
local function copied_target(src, dst, target, opts)
    local src_dir = vim.fs.dirname(src)
    local dst_dir = vim.fs.dirname(dst)
    local abs_target = is_absolute(target) and path.abs(target)
        or path.abs(path.join_abs(src_dir, target))

    -- A staged move copies from a transaction path that is deleted afterwards.
    -- Links into the moved tree must follow it to the destination tree instead
    -- of being rebased against the temporary source.
    if opts and opts.move and opts.dest_root then
        for _, root in ipairs { opts.source_root, opts.original_root } do
            if root and is_within(root, abs_target) then
                local relative = path.relpath(root, abs_target)
                local mapped = path.join_abs(opts.dest_root, relative)
                local mapped_rel = path.relpath(dst_dir, mapped)
                return mapped_rel and mapped_rel ~= "" and mapped_rel or mapped
            end
        end
    end

    if is_absolute(target) then
        return target
    end
    -- A relative link is interpreted against the directory holding the link.
    -- When the copy lands in another directory, rebase it so it still resolves
    -- to the same file instead of pointing at a different (or missing) path.
    local rel = path.relpath(dst_dir, abs_target)
    if not rel or rel == "" then
        return abs_target
    end
    return rel
end

---@param src string
---@param dst string
---@param opts? {move?: boolean, source_root?: string, original_root?: string, dest_root?: string}
---@return boolean, string?
function M.copy_symlink(src, dst, opts)
    if not uv.fs_readlink or not uv.fs_symlink then
        return false, "symlink copy not supported"
    end
    if stat.exists(dst) then
        return false, "target exists: " .. dst
    end
    local target, err_name, err_msg = uv.fs_readlink(src)
    if not target then
        return false, (err_name or "fs_readlink") .. ": " .. (err_msg or "")
    end
    local new_target = copied_target(src, dst, target, opts)
    local ok, err_name2, err_msg2 = uv.fs_symlink(new_target, dst)
    if not ok then
        return false, (err_name2 or "fs_symlink") .. ": " .. (err_msg2 or "")
    end
    return true
end

return M
