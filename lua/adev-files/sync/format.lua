local path = require "adev-files.utils.fs.path"

local M = {}

---@param st AdevFilesState
---@param ops AdevFilesOp[]
---@return string[]
function M.format_ops(st, ops)
    local lines = {}
    for _, op in ipairs(ops) do
        if op.type == "create" then
            local p = path.relpath(st.root, op.path)
            if op.kind == "directory" and p:sub(-1) ~= "/" then
                p = p .. "/"
            end
            table.insert(lines, string.format("create: %s", p))
        elseif op.type == "delete" then
            local p = path.relpath(st.root, op.path)
            if op.kind == "directory" and p:sub(-1) ~= "/" then
                p = p .. "/"
            end
            table.insert(lines, string.format("delete: %s", p))
        elseif op.type == "rename" then
            local src = path.relpath(st.root, op.src)
            local dst = path.relpath(st.root, op.dst)
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
            local src = path.relpath(st.root, op.src)
            local dst = path.relpath(st.root, op.dst)
            table.insert(lines, string.format("copy: %s -> %s", src, dst))
        elseif op.type == "move" then
            local src = path.relpath(st.root, op.src)
            local dst = path.relpath(st.root, op.dst)
            table.insert(lines, string.format("move: %s -> %s", src, dst))
        end
    end

    if #lines == 0 then
        return { "(no changes)" }
    end

    table.sort(lines)
    return lines
end

return M
