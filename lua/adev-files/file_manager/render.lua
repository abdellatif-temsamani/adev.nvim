local M = {}

local clipboard = require "adev-files.clipboard"
local git = require "adev-files.git"
local icons = require "adev-files.icon"
local listing = require "adev-files.file_manager.listing"
local path = require "adev-files.utils.fs.path"
local state = require "adev-files.state"
local view = require "adev-files.core.view"
local win = require "adev-files.file_manager.window"

---@type table<string, string>
local GIT_LABEL = {
    M = "M",
    A = "A",
    D = "D",
    R = "R",
    C = "C",
    ["?"] = "?",
}

---@type table<string, string>
local GIT_HL = {
    M = "adevFilesGitModified",
    A = "adevFilesGitAdded",
    D = "adevFilesGitDeleted",
    R = "adevFilesGitRenamed",
    C = "adevFilesGitCopied",
    ["?"] = "adevFilesGitUntracked",
}

---@param status string|nil
---@return string|nil, string|nil
local function git_indicator(status)
    if not status then
        return nil, nil
    end
    return GIT_LABEL[status], GIT_HL[status]
end

--- Build a map of source paths -> mode from the clipboard
---@return table<string, string>
local function build_clipboard_sources()
    local clip = clipboard.get()
    if not clip or not clip.items then
        return {}
    end
    local sources = {}
    for _, item in ipairs(clip.items) do
        if item.src then
            sources[path.abs(item.src)] = clip.mode
        end
    end
    return sources
end

--- Update window title with file/dir/pending counts
---@param buf integer
---@param root string
---@param entries { row: integer, entry: AdevFilesEntry }[]
local function update_title(buf, root, entries)
    local dir_count = 0
    local file_count = 0
    for _, item in ipairs(entries) do
        if item.entry.kind == "directory" then
            dir_count = dir_count + 1
        else
            file_count = file_count + 1
        end
    end
    local total = dir_count + file_count
    win.set_title_from_state(buf, root, total)
end

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

    update_title(buf, root, entries)

    local original_lines = state.get_original_lines(buf)
    local original_by_path = {}
    local original_row_by_path = {}
    for row, o in pairs(original_lines) do
        if o.abs_path then
            original_by_path[o.abs_path] = o.entry
            original_row_by_path[o.abs_path] = row
        end
    end

    local consumed = {}
    local matched = {}
    for _, item in ipairs(entries) do
        if not item.deleted then
            local abs_path = path.join_abs(root, item.entry.fs_name)
            if original_by_path[abs_path] then
                local orig_row = original_row_by_path[abs_path]
                if orig_row then
                    consumed[orig_row] = true
                end
                matched[item.row] = true
            end
        end
    end

    local original_by_name = {}
    for row, o in pairs(original_lines) do
        if not consumed[row] then
            local name = o.entry.fs_name
            original_by_name[name] = original_by_name[name] or {}
            table.insert(original_by_name[name], { row = row, entry = o.entry, abs_path = o.abs_path })
        end
    end

    for _, item in ipairs(entries) do
        if not item.deleted and not matched[item.row] then
            local candidates = original_by_name[item.entry.fs_name]
            if candidates and #candidates > 0 then
                for i, c in ipairs(candidates) do
                    if c.entry.kind == item.entry.kind then
                        consumed[c.row] = true
                        matched[item.row] = true
                        table.remove(candidates, i)
                        break
                    end
                end
            end
        end
    end

    local clip_sources = build_clipboard_sources()

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

    local selection_marks = state.get_selection_marks(buf)
    local git_status = state.get_git_status(buf)

    for _, item in ipairs(entries) do
        local parsed = item.entry
        local row = item.row
        if parsed then
            local icon, hl = icons.get_entry_icon(parsed.name)
            local virt_text = {}
            if selection_marks[row] then
                table.insert(virt_text, { "● ", "adevFilesPendingMark" })
            end
            local entry_prefix = icon ~= "" and (icon .. " ") or "  "
            if parsed.kind == "directory" then
                entry_prefix = "▸ " .. entry_prefix
            end
            table.insert(virt_text, { entry_prefix, hl ~= "" and hl or "Normal" })
            vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
                virt_text = virt_text,
                virt_text_pos = "inline",
            })

            local suffix = {}
            local gs, gs_hl = git_indicator(git.get_file_status(git_status, parsed.fs_name))
            if gs then
                table.insert(suffix, { "[" .. gs .. "]", gs_hl })
            end
            local abs_path = path.join_abs(root, parsed.fs_name)
            local original = original_by_path[abs_path]
            if not original and not matched[item.row] then
                local orig_line = original_lines[row]
                if orig_line and not consumed[row] then
                    original = orig_line.entry
                end
            end
            local deleted_item = pending_delete[abs_path]
            local clip_mode = clip_sources[abs_path]

            if not deleted_item then
                if original then
                    if parsed.fs_name ~= original.fs_name then
                        table.insert(suffix, { " | renamed |", "adevFilesPendingMark" })
                    end
                elseif not clip_mode and (not pending_by_path[abs_path] or #pending_by_path[abs_path] == 0) then
                    table.insert(suffix, { " | new |", "adevFilesPendingMark" })
                end
            end

            if deleted_item and not clip_mode then
                table.insert(suffix, { " | delete |", "adevFilesPendingDelete" })
            end

            if clip_mode then
                local label = clip_mode == "move" and " | move |" or " | copy |"
                local hl_name = clip_mode == "move" and "adevFilesPendingMove" or "adevFilesPendingCopy"
                table.insert(suffix, { label, hl_name })
            end

            local pending_ops = pending_by_path[abs_path]
            if pending_ops and #pending_ops > 0 then
                for _, op in ipairs(pending_ops) do
                    local src_rel = path.relpath(root, op.src or "")
                    local label = op.type == "move" and " | moved from " or " | copied from "
                    local hl_name = op.type == "move" and "adevFilesPendingMove"
                        or "adevFilesPendingCopy"
                    table.insert(suffix, { label .. src_rel .. " |", hl_name })
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

    -- Footer line as virt_lines below last entry
    local footer_line = listing.build_footer_line(buf, entries)
    local anchor_row = #entries > 0 and entries[#entries].row
        or vim.api.nvim_buf_line_count(buf) - 1
    vim.api.nvim_buf_set_extmark(buf, ns, anchor_row, 0, {
        virt_lines = {
            { { footer_line, "Comment" } },
        },
        virt_lines_above = false,
    })
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
    local st = state.get(buf)
    local opts = {}
    if st then
        opts.show_hidden = st.show_hidden
    end
    view.render(buf, root, opts)
end

return M
