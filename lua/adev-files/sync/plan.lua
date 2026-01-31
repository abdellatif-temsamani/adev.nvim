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

    -- Build map of current entries by their absolute path
    local current_entries_by_path = {}
    for i = 1, #lines do
        local entry, err = parse.parse_line(lines[i])
        if err then
            return nil, string.format("line %d: %s", i, err)
        end
        if entry then
            local abs_path = join(st.root, entry.fs_name)
            if current_entries_by_path[abs_path] then
                return nil, string.format("duplicate entry: '%s'", entry.fs_name)
            end
            current_entries_by_path[abs_path] = {
                row = i - 1,
                entry = entry,
            }
        end
    end

    -- Build set of original paths for quick lookup
    local original_paths = {}
    for _, mark in pairs(st.marks) do
        original_paths[mark.abs_path] = mark
    end

    ---@type AdevFilesOp[]
    local ops = {}

    -- Detect creates: entries in current but not in original
    for path, info in pairs(current_entries_by_path) do
        if not original_paths[path] then
            -- This path didn't exist before, it's a create
            table.insert(ops, {
                type = "create",
                kind = info.entry.kind,
                path = path,
            })
        end
    end

    -- Get extmarks to handle renames vs creates at extmark positions
    local extmarks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, {})
    local row_to_extmark = {}
    for _, m in ipairs(extmarks) do
        local id, row = m[1], m[2]
        row_to_extmark[row] = { id = id, row = row }
    end

    -- Handle entries at extmark positions (potential renames or unchanged)
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
                -- Row is empty or unparsable - mark for deletion
                -- (will be handled in deletes section if path not found elsewhere)
            else
                if entry.kind ~= orig.kind then
                    return nil, string.format("line %d: cannot change kind", row + 1)
                end
                if entry.fs_name ~= orig.fs_name then
                    -- Different name at this extmark's row
                    -- Check if the original file still exists elsewhere
                    if not current_entries_by_path[orig.abs_path] then
                        -- Original doesn't exist elsewhere, so this is a rename
                        table.insert(ops, {
                            type = "rename",
                            kind = orig.kind,
                            src = orig.abs_path,
                            dst = join(st.root, entry.fs_name),
                        })
                    end
                    -- If original does exist elsewhere, the create was already added above
                end
            end
        end
    end

    -- Detect deletes: original entries not found in current
    for _, orig in pairs(st.marks) do
        if not current_entries_by_path[orig.abs_path] then
            -- Check if this original was renamed (has a rename op from it)
            local was_renamed = false
            for _, op in ipairs(ops) do
                if op.type == "rename" and op.src == orig.abs_path then
                    was_renamed = true
                    break
                end
            end
            if not was_renamed then
                -- Original path is gone and wasn't renamed - it's a delete
                table.insert(ops, {
                    type = "delete",
                    kind = orig.kind,
                    path = orig.abs_path,
                })
            end
        end
    end

    return ops, nil
end

return M
