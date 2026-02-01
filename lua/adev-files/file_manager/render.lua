local M = {}

local icons = require "adev-files.icon"
local listing = require "adev-files.file_manager.listing"
local parse = require "adev-files.parse"
local state = require "adev-files.state"

--- Add virtual text header and icons to buffer
---@param buf integer
---@param root string
---@param lines string[]
local function add_virtual_text(buf, root, lines)
    local ns = state.display_ns()
    local mark_ns = state.ns()
    local st = state.get(buf)
    local marks_by_row = {}
    local current_paths = {}
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    if st then
        for _, line in ipairs(lines) do
            local parsed = select(1, parse.parse_line(line))
            if parsed then
                current_paths[st.root .. parsed.fs_name] = true
            end
        end
    end

    if st and st.original_marks then
        local extmarks = vim.api.nvim_buf_get_extmarks(buf, mark_ns, 0, -1, {})
        for _, m in ipairs(extmarks) do
            local id, row = m[1], m[2]
            marks_by_row[row] = st.original_marks[id]
        end
    end

    -- Build virtual header lines
    local header = listing.build_header(root)
    local virt_lines = {}
    for _, item in ipairs(header) do
        table.insert(virt_lines, { { item[1], item[2] } })
    end

    -- Add header as virtual lines above first line
    if #lines > 0 then
        vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
            virt_lines = virt_lines,
            virt_lines_above = true,
        })
    else
        -- Empty directory - still show header but on a placeholder line
        vim.bo[buf].modifiable = true
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
        vim.bo[buf].modified = false
        vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
            virt_lines = virt_lines,
            virt_lines_above = true,
        })
    end

    -- Add icon virtual text for each entry
    for i, entry in ipairs(lines) do
        local icon, hl = icons.get_entry_icon(entry)
        local prefix = icon ~= "" and (icon .. " ") or "  "
        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
            virt_text = { { prefix, hl ~= "" and hl or "Normal" } },
            virt_text_pos = "inline",
        })

        local mark = marks_by_row[i - 1]
        local parsed = select(1, parse.parse_line(entry))
        if parsed then
            if mark then
                if parsed.fs_name ~= mark.fs_name then
                    if not current_paths[mark.abs_path] then
                        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                            virt_text = { { "  R rename", "DiffChange" } },
                            virt_text_pos = "eol",
                        })
                    else
                        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                            virt_text = { { "  + create", "DiffAdd" } },
                            virt_text_pos = "eol",
                        })
                    end
                end
            else
                vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                    virt_text = { { "  + create", "DiffAdd" } },
                    virt_text_pos = "eol",
                })
            end
        end
    end
end

--- Add virtual text only (when lines are already set in buffer)
---@param buf integer
---@param root string
function M.add_virtual_text(buf, root)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    add_virtual_text(buf, root, lines)
end

---@param buf integer
---@param root string
function M.render(buf, root)
    local lines = listing.build_lines(root)

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false

    add_virtual_text(buf, root, lines)
end

return M
