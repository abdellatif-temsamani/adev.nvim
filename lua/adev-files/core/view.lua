local listing = require "adev-files.file_manager.listing"
local parse = require "adev-files.parse"

local M = {}

---@param buf integer
---@param root string
---@return string[]
function M.render(buf, root)
    local lines = listing.build_lines(root)
    if #lines == 0 then
        lines = { "" }
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
        local _, deleted = parse.strip_delete_marker(line)
        local entry, err = parse.parse_line(line)
        if err then
            return nil, string.format("line %d: %s", i, err)
        end
        if entry then
            table.insert(entries, { row = i - 1, entry = entry, deleted = deleted })
        end
    end

    return entries, nil
end

return M
