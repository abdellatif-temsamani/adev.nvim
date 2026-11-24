local listing = require "adev-files.file_manager.listing"
local parse = require "adev-files.parse"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@param root string
---@param opts? { show_hidden?: boolean, lines?: string[] }
---@return string[]
function M.render(buf, root, opts)
    local entries, err
    if opts and opts.lines then
        entries = opts.lines
    else
        entries, err = listing.build_lines(root, opts)
    end
    if not entries then
        return nil, err
    end
    state.clear_selection_marks(buf)
    if #entries == 0 then
        entries = { "" }
    end
    -- Row 0 is a display-only anchor for the virtual header. Filesystem
    -- entries start at row 1 and are the only editable content.
    local lines = { "" }
    for _, l in ipairs(entries) do
        table.insert(lines, l)
    end
    -- The buffer may be locked after an apply or while a refresh is pending.
    -- Unlock only for the write itself, then restore the state's intent so a
    -- failed or deferred refresh does not silently make entries editable.
    local st = state.get(buf)
    local desired_modifiable = vim.bo[buf].modifiable
    if st then
        if st.refresh_modifiable ~= nil then
            desired_modifiable = st.refresh_modifiable
        elseif st.needs_refresh then
            desired_modifiable = false
        end
    end
    vim.bo[buf].modifiable = true
    local ok, set_err = pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
    vim.bo[buf].modified = false
    vim.bo[buf].modifiable = desired_modifiable and true or false
    if not ok then
        return nil, tostring(set_err)
    end
    return lines
end

---@param buf integer
---@return { row: integer, entry: AdevFilesEntry, deleted: boolean }[]|nil, string|nil, integer|nil
function M.parse_buffer(buf, opts)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local entries = {}

    for i, line in ipairs(lines) do
        if i == 1 then
            if line ~= "" and not (opts and opts.tolerant) then
                return nil, "the header row must remain empty", i - 1
            end
            goto continue
        end
        local _, deleted = parse.strip_delete_marker(line)
        local entry, err = parse.parse_line(line)
        if err then
            if not (opts and opts.tolerant) then
                return nil, string.format("line %d: %s", i, err), i - 1
            end
        end
        if entry then
            table.insert(entries, { row = i - 1, entry = entry, deleted = deleted })
        end
        ::continue::
    end

    return entries, nil
end

return M
