local parse = require "adev-files.parse"
local state = require "adev-files.state"

local M = {}

---@class AdevFilesOp
---@field type 'create'|'delete'|'rename'|'copy'|'move'
---@field kind? 'file'|'directory'
---@field path? string
---@field src? string
---@field dst? string

---@param root string
---@param fs_name string
---@return string
local function join(root, fs_name)
    return root .. fs_name
end

---@param buf integer
---@return AdevFilesOp[]|nil, string|nil
function M.plan_ops(buf)
    local st = state.get(buf)
    if not st then
        return nil, "missing state"
    end

    local ns = state.ns()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local extmarks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})

    local row_to_id = {}
    local present = {}
    for _, m in ipairs(extmarks) do
        local id, row = m[1], m[2]
        row_to_id[row] = id
        present[id] = true
    end

    -- validate desired entries and detect duplicates
    local desired = {}
    for i = 1, #lines do
        local entry, err = parse.parse_line(lines[i])
        if err then
            return nil, string.format("line %d: %s", i, err)
        end
        if entry then
            local abs = join(st.root, entry.fs_name)
            if desired[abs] then
                return nil, string.format("duplicate entry: '%s'", entry.fs_name)
            end
            desired[abs] = true
        end
    end

    ---@type AdevFilesOp[]
    local ops = {}

    -- existing entries (tracked by extmarks)
    for _, m in ipairs(extmarks) do
        local id, row = m[1], m[2]
        local orig = st.marks[id]
        if orig then
            local line = lines[row + 1] or ""
            local entry, err = parse.parse_line(line)
            if err then
                return nil, string.format("line %d: %s", row + 1, err)
            end
            if not entry then
                table.insert(ops, { type = "delete", kind = orig.kind, path = orig.abs_path })
            else
                if entry.kind ~= orig.kind then
                    return nil, string.format("line %d: cannot change kind", row + 1)
                end
                if entry.fs_name ~= orig.fs_name then
                    table.insert(ops, {
                        type = "rename",
                        kind = orig.kind,
                        src = orig.abs_path,
                        dst = join(st.root, entry.fs_name),
                    })
                end
            end
        end
    end

    -- deleted lines (extmark removed)
    for id, orig in pairs(st.marks) do
        if not present[id] then
            table.insert(ops, { type = "delete", kind = orig.kind, path = orig.abs_path })
        end
    end

    -- new lines (no extmark)
    for i = 1, #lines do
        local row = i - 1
        if not row_to_id[row] then
            local entry, err = parse.parse_line(lines[i])
            if err then
                return nil, string.format("line %d: %s", i, err)
            end
            if entry then
                table.insert(
                    ops,
                    { type = "create", kind = entry.kind, path = join(st.root, entry.fs_name) }
                )
            end
        end
    end

    return ops, nil
end

return M
