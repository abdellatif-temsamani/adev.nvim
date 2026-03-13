local M = {}

local icons = require "adev-files.icon"
local state = require "adev-files.state"
local view = require "adev-files.core.view"
local marks = require "adev-files.core.marks"
local model = require "adev-files.core.model"
local path = require "adev-files.utils.fs.path"

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
    local row_to_id = marks.sync(buf, entries)
    local current_model = st.model or model.new(root)
    local projection = model.project(current_model, entries, row_to_id)
    state.set_view(buf, projection)

    local pending_delete = {}
    local pending_by_id = {}
    local pending_by_path = {}
    if st.pending_ops then
        for _, op in ipairs(st.pending_ops) do
            if op.type == "delete" and op.path then
                pending_delete[op.path] = true
            elseif (op.type == "copy" or op.type == "move") and op.src then
                if op.dst_id then
                    pending_by_id[op.dst_id] = pending_by_id[op.dst_id] or {}
                    table.insert(pending_by_id[op.dst_id], op)
                elseif op.dst then
                    pending_by_path[op.dst] = pending_by_path[op.dst] or {}
                    table.insert(pending_by_path[op.dst], op)
                end
            end
        end
    end

    -- Add icon virtual text for each entry
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
            local node_id = row_to_id[row]
            local pending_ops = node_id and pending_by_id[node_id] or nil
            local is_pending = pending_ops and #pending_ops > 0
            local abs_path = st.root .. parsed.fs_name
            if not pending_ops then
                pending_ops = pending_by_path[abs_path]
                is_pending = pending_ops and #pending_ops > 0
            end
            local deleted = is_deleted or pending_delete[abs_path]
            local original = node_id and current_model.original_by_id[node_id] or nil
            if not original then
                local original_id = current_model.original_by_path[abs_path]
                original = original_id and current_model.original_by_id[original_id] or nil
            end

            if not deleted then
                if original then
                    if parsed.fs_name ~= original.fs_name then
                        if not projection.current_by_path[original.abs_path] then
                            table.insert(suffix, { "  R rename", "DiffChange" })
                        else
                            table.insert(suffix, { "  + create", "DiffAdd" })
                        end
                    end
                elseif not is_pending then
                    table.insert(suffix, { "  + create", "DiffAdd" })
                end
            end

            if deleted then
                table.insert(suffix, { "  D delete", "adevFilesPendingDelete" })
            end

            if st and pending_ops and #pending_ops > 0 then
                for _, op in ipairs(pending_ops) do
                    local src_rel = path.relpath(st.root, op.src or "")
                    local label = op.type == "move" and "  moved from " or "  copied from "
                    local hl = op.type == "move" and "adevFilesPendingMove" or "adevFilesPendingCopy"
                    table.insert(suffix, { label .. src_rel, hl })
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
