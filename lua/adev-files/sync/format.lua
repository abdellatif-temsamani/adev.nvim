local M = {}

---@param root string
---@param abs string
---@return string
local function relpath(root, abs)
    if abs:sub(1, #root) == root then
        local rel = abs:sub(#root + 1)
        if rel:sub(1, 1) == "/" then
            rel = rel:sub(2)
        end
        return rel
    end
    return abs
end

---@param st AdevFilesState
---@param ops AdevFilesOp[]
---@return string[]
function M.format_ops(st, ops)
    local lines = {}
    for _, op in ipairs(ops) do
        if op.type == "create" then
            local p = relpath(st.root, op.path)
            if op.kind == "directory" and p:sub(-1) ~= "/" then
                p = p .. "/"
            end
            table.insert(lines, string.format("create: %s", p))
        elseif op.type == "delete" then
            local p = relpath(st.root, op.path)
            if op.kind == "directory" and p:sub(-1) ~= "/" then
                p = p .. "/"
            end
            table.insert(lines, string.format("delete: %s", p))
        elseif op.type == "rename" then
            local src = relpath(st.root, op.src)
            local dst = relpath(st.root, op.dst)
            if op.kind == "directory" then
                if src:sub(-1) ~= "/" then
                    src = src .. "/"
                end
                if dst:sub(-1) ~= "/" then
                    dst = dst .. "/"
                end
            end
            table.insert(lines, string.format("rename: %s -> %s", src, dst))
        elseif op.type == "copy" then
            table.insert(lines, string.format("copy: %s -> %s", op.src, op.dst))
        elseif op.type == "move" then
            table.insert(lines, string.format("move: %s -> %s", op.src, op.dst))
        end
    end

    if #lines == 0 then
        return { "(no changes)" }
    end

    table.sort(lines)
    return lines
end

return M
