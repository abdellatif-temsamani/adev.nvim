local M = {}

local icons = require "adev-files.icon"
local listing = require "adev-files.file_manager.listing"
local parse = require "adev-files.parse"
local state = require "adev-files.state"

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

--- Add virtual text icons to buffer
---@param buf integer
---@param root string
---@param lines string[]
local function add_virtual_text(buf, root, lines)
    local ns = state.display_ns()
    local mark_ns = state.ns()
    local st = state.get(buf)
    local marks_by_row = {}
    local marks_by_path = {}
    local current_paths = {}
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    if st then
        for _, line in ipairs(lines) do
            local clean, is_deleted = parse.strip_delete_marker(line)
            if not is_deleted then
                local parsed = select(1, parse.parse_line(clean))
                if parsed then
                    current_paths[st.root .. parsed.fs_name] = true
                end
            end
        end
    end

    local pending_delete = {}
    local pending_by_row = {}
    if st and st.pending_ops then
        local pending_ns = state.pending_ns()
        for _, op in ipairs(st.pending_ops) do
            if op.type == "delete" and op.path then
                pending_delete[op.path] = true
            elseif (op.type == "copy" or op.type == "move") and op.src and op.mark_id then
                local pos = vim.api.nvim_buf_get_extmark_by_id(buf, pending_ns, op.mark_id, {})
                if pos and #pos > 0 then
                    local row = pos[1]
                    pending_by_row[row] = pending_by_row[row] or {}
                    table.insert(pending_by_row[row], op)
                end
            end
        end
    end

    if st and st.original_marks then
        for _, mark in pairs(st.original_marks) do
            marks_by_path[mark.abs_path] = mark
        end
        local extmarks = vim.api.nvim_buf_get_extmarks(buf, mark_ns, 0, -1, {})
        for _, m in ipairs(extmarks) do
            local id, row = m[1], m[2]
            marks_by_row[row] = st.original_marks[id]
        end
    end

    -- Add icon virtual text for each entry
    for i, entry in ipairs(lines) do
        local clean, is_deleted = parse.strip_delete_marker(entry)
        local parsed = select(1, parse.parse_line(clean))
        if parsed then
            local icon, hl = icons.get_entry_icon(parsed.name)
            local prefix = icon ~= "" and (icon .. " ") or "  "
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                virt_text = { { prefix, hl ~= "" and hl or "Normal" } },
                virt_text_pos = "inline",
            })

            local suffix = {}
            local pending_ops = pending_by_row[i - 1]
            local is_pending = pending_ops and #pending_ops > 0
            local abs_path = st and (st.root .. parsed.fs_name) or nil
            local deleted = is_deleted or (abs_path and pending_delete[abs_path])
            local mark = marks_by_row[i - 1]
            if not mark and abs_path then
                mark = marks_by_path[abs_path]
            end

            if not deleted then
                if mark then
                    if parsed.fs_name ~= mark.fs_name then
                        if not current_paths[mark.abs_path] then
                            table.insert(suffix, { "  R rename", "DiffChange" })
                        else
                            table.insert(suffix, { "  + create", "DiffAdd" })
                        end
                    end
                else
                    if not is_pending then
                        table.insert(suffix, { "  + create", "DiffAdd" })
                    end
                end
            end

            if deleted then
                table.insert(suffix, { "  D delete", "adevFilesPendingDelete" })
            end

            if st and pending_ops and #pending_ops > 0 then
                for _, op in ipairs(pending_ops) do
                    local src_rel = relpath(st.root, op.src or "")
                    local label = op.type == "move" and "  moved from " or "  copied from "
                    local hl = op.type == "move" and "adevFilesPendingMove" or "adevFilesPendingCopy"
                    table.insert(suffix, { label .. src_rel, hl })
                end
            end

            if #suffix > 0 then
                vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                    virt_text = suffix,
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
    if #lines == 0 then
        lines = { "" }
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false

    add_virtual_text(buf, root, lines)
end

return M
