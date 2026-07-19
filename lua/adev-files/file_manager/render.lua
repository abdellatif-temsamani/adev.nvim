local M = {}

local icons = require "adev-files.icon"
local path = require "adev-files.utils.fs.path"
local state = require "adev-files.state"
local view = require "adev-files.core.view"

--- Add virtual text icons to buffer
---@param buf integer
---@param root string
local function add_virtual_text(buf, root)
    local ns = state.display_ns()
    local st = state.get(buf)
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    if not st then
        return
    end

    local entries, err = view.parse_buffer(buf)
    if err then
        return
    end

    local original_lines = state.get_original_lines(buf)

    local pending_delete = {}
    local pending_by_path = {}
    if st.pending_ops then
        for _, op in ipairs(st.pending_ops) do
            if op.type == "delete" and op.path then
                pending_delete[op.path] = true
            elseif (op.type == "copy" or op.type == "move") and op.src then
                if op.dst then
                    local dst = path.abs(op.dst)
                    pending_by_path[dst] = pending_by_path[dst] or {}
                    table.insert(pending_by_path[dst], op)
                end
            end
        end
    end

    for _, item in ipairs(entries) do
        local parsed = item.entry
        local row = item.row
        local is_deleted = item.deleted
        if parsed then
            local icon, hl = icons.get_entry_icon(parsed.name)
            local prefix = icon ~= "" and (icon .. " ") or "  "
            vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
                virt_text = { { prefix, hl ~= "" and hl or "Normal" } },
                virt_text_pos = "inline",
            })

            local suffix = {}
            local abs_path = path.join_abs(root, parsed.fs_name)
            local original = original_lines[row]
            local deleted = is_deleted or pending_delete[abs_path]

            if not deleted then
                if original then
                    if parsed.fs_name ~= original.entry.fs_name then
                        table.insert(suffix, { "  R rename", "DiffChange" })
                    end
                elseif not pending_by_path[abs_path] or #pending_by_path[abs_path] == 0 then
                    table.insert(suffix, { "  + create", "DiffAdd" })
                end
            end

            if deleted then
                table.insert(suffix, { "  D delete", "adevFilesPendingDelete" })
            end

            local pending_ops = pending_by_path[abs_path]
            if pending_ops and #pending_ops > 0 then
                for _, op in ipairs(pending_ops) do
                    local src_rel = path.relpath(root, op.src or "")
                    local label = op.type == "move" and "  moved from " or "  copied from "
                    local hl_name = op.type == "move" and "adevFilesPendingMove"
                        or "adevFilesPendingCopy"
                    table.insert(suffix, { label .. src_rel, hl_name })
                end
            end

            if #suffix > 0 then
                vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
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
    add_virtual_text(buf, root)
end

---@param buf integer
---@param root string
function M.render(buf, root)
    view.render(buf, root)
end

return M
