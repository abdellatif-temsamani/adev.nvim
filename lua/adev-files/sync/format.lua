local path = require "adev-files.utils.fs.path"

local M = {}

local MAX_DELETE_PREVIEW_DESCENDANTS = 1000

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
            local prefix = "delete: "
            if op.kind == "directory" then
                local uv = vim.uv or vim.loop
                local stat = uv.fs_stat(op.path)
                if stat and stat.type == "directory" then
                    local count = 0
                    local scan_errors = {}
                    local capped = false
                    local pending = { op.path }
                    while #pending > 0 and not capped do
                        local dir = table.remove(pending)
                        local handle, scan_err = uv.fs_scandir(dir)
                        if not handle then
                            table.insert(
                                scan_errors,
                                "fs_scandir " .. dir .. ": " .. tostring(scan_err)
                            )
                        else
                            while true do
                                local name, typ, next_err = uv.fs_scandir_next(handle)
                                if not name then
                                    local detail = next_err
                                        or (type(typ) == "string" and typ or nil)
                                    if detail then
                                        table.insert(
                                            scan_errors,
                                            "fs_scandir_next " .. dir .. ": " .. tostring(detail)
                                        )
                                    end
                                    break
                                end
                                if count >= MAX_DELETE_PREVIEW_DESCENDANTS then
                                    capped = true
                                    break
                                end
                                count = count + 1
                                if typ == "directory" then
                                    table.insert(pending, vim.fs.joinpath(dir, name))
                                end
                            end
                        end
                    end
                    prefix = string.format(
                        "recursive delete (%s%d descendants): ",
                        (capped or #scan_errors > 0) and "at least " or "",
                        count
                    )
                    if #scan_errors > 0 then
                        p = p .. " (incomplete scan: " .. table.concat(scan_errors, "; ") .. ")"
                    end
                end
            end
            table.insert(lines, prefix .. p)
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
