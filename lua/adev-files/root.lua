local M = {}

---@param root string
---@return string
function M.normalize_root(root)
    root = vim.fn.fnamemodify(root and root ~= "" and root or ".", ":p")
    root = vim.fs.normalize(root, { expand_env = false })
    if root:sub(-1) ~= "/" then
        root = root .. "/"
    end
    return root
end

---@param root string
---@param fs_name string
---@return string
function M.child_root(root, fs_name)
    root = M.normalize_root(root)
    if not fs_name or fs_name == "" then
        return root
    end
    return M.normalize_root(root .. fs_name)
end

---@param root string
---@return string
function M.parent_root(root)
    root = M.normalize_root(root)
    local r = root:gsub("/$", "")
    if r == "" then
        return "/"
    end
    local parent = vim.fs.dirname(r)
    if not parent or parent == "" or parent == "." then
        return "./"
    end
    return M.normalize_root(parent)
end

return M
