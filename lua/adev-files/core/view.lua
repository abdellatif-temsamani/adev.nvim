local listing = require "adev-files.file_manager.listing"
local parse = require "adev-files.parse"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@param root string
---@param opts? { show_hidden?: boolean }
---@return string[]
function M.render(buf, root, opts)
    state.clear_selection_marks(buf)
    local entries = listing.build_lines(root, opts)
    if #entries == 0 then
        entries = { "" }
    end
    -- Row 0 is a display-only anchor for the virtual header. Filesystem
    -- entries start at row 1 and are the only editable content.
    local lines = { "" }
    for _, l in ipairs(entries) do
        table.insert(lines, l)
    end
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false
    return lines
end

---@param buf integer
---@return { row: integer, entry: AdevFilesEntry, deleted: boolean }[]|nil, string|nil
function M.parse_buffer(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local entries = {}

    for i, line in ipairs(lines) do
        if i == 1 then
            goto continue
        end
        local _, deleted = parse.strip_delete_marker(line)
        local entry, err = parse.parse_line(line)
        if err then
            return nil, string.format("line %d: %s", i, err)
        end
        if entry then
            table.insert(entries, { row = i - 1, entry = entry, deleted = deleted })
        end
        ::continue::
    end

    return entries, nil
end

return M
