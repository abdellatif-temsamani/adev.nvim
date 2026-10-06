local M = {}

local uv = vim.uv or vim.loop
local clipboard = require "adev-files.clipboard"
local git = require "adev-files.git"
local icons = require "adev-files.icon"
local listing = require "adev-files.file_manager.listing"
local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"
local plan = require "adev-files.sync.plan"
local state = require "adev-files.state"
local view = require "adev-files.core.view"
local win = require "adev-files.file_manager.window"

---@type table<string, string>
local GIT_LABEL = {
    U = "U",
    M = "M",
    A = "A",
    D = "D",
    R = "R",
    C = "C",
    ["?"] = "?",
}

---@type table<string, string>
local GIT_HL = {
    U = "adevFilesGitConflict",
    M = "adevFilesGitModified",
    A = "adevFilesGitAdded",
    D = "adevFilesGitDeleted",
    R = "adevFilesGitRenamed",
    C = "adevFilesGitCopied",
    ["?"] = "adevFilesGitUntracked",
}

local function format_mode(mode)
    if not mode then
        return nil
    end
    local perm = mode % 512
    local result = {}
    local bits = { 256, 128, 64, 32, 16, 8, 4, 2, 1 }
    for i = 1, 9 do
        if perm >= bits[i] then
            perm = perm - bits[i]
            result[i] = ({ "r", "w", "x", "r", "w", "x", "r", "w", "x" })[i]
        else
            result[i] = "-"
        end
    end
    return table.concat(result)
end

local HEADER_WIDTH = 72

---@param status string|nil
---@return string|nil, string|nil
local function git_indicator(status)
    if not status then
        return nil, nil
    end
    return GIT_LABEL[status], GIT_HL[status]
end

---@param summary AdevFilesSummary
---@return table[]
local function summary_chunks(summary)
    local chunks = {
        { "│ ", "Comment" },
        { string.format("%d files", summary.files), "Normal" },
        { "  •  ", "Comment" },
        { string.format("%d dirs", summary.directories), "Normal" },
    }

    if summary.pending > 0 then
        table.insert(chunks, { "  •  ", "Comment" })
        table.insert(
            chunks,
            { string.format("%d pending", summary.pending), "adevFilesPendingMark" }
        )
    end
    if summary.show_hidden then
        table.insert(chunks, { "  •  hidden", "Comment" })
    end

    local has_git = false
    for _, code in ipairs { "U", "M", "A", "D", "R", "C", "?" } do
        if summary.git_counts[code] and summary.git_counts[code] > 0 then
            if not has_git then
                table.insert(chunks, { "  •  Git ", "Comment" })
                has_git = true
            end
            table.insert(chunks, {
                string.format("%s:%d ", code, summary.git_counts[code]),
                GIT_HL[code] or "Comment",
            })
        end
    end

    return chunks
end

---@return table[]
local function title_chunks()
    local prefix = "╭─ "
    local title = "adev-files"
    local suffix_width = math.max(1, HEADER_WIDTH - vim.fn.strdisplaywidth(prefix .. title) - 2)
    return {
        { prefix, "Comment" },
        { title, "Title" },
        { " " .. string.rep("─", suffix_width) .. "╮", "Comment" },
    }
end

---@param chunks table[]
---@return table[]
local function close_box(chunks)
    local width = 0
    for _, chunk in ipairs(chunks) do
        width = width + vim.fn.strdisplaywidth(chunk[1])
    end
    if width < HEADER_WIDTH then
        table.insert(chunks, {
            string.rep(" ", math.max(1, HEADER_WIDTH - width - 1)) .. "│",
            "Comment",
        })
    end
    return chunks
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

    local entries = view.parse_buffer(buf, { tolerant = true })

    update_title(buf, root, entries)

    local ops, plan_error, row_changes = plan.plan_ops(buf)
    row_changes = row_changes or {}
    vim.bo[buf].modified = not st.needs_refresh and (plan_error ~= nil or (ops and #ops > 0))
        or false

    -- Conceal every ID, including temporarily invalid rows during editing.
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        local _, _, prefix_length = parse.strip_id(line)
        if prefix_length > 0 then
            vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
                end_col = prefix_length,
                conceal = "",
            })
        end
    end

    local clip_sources = build_clipboard_sources()
    local move_sources = {}
    for _, op in ipairs(ops or {}) do
        if op.type == "move" then
            move_sources[op.src] = true
        end
    end
    local selection_marks = state.get_selection_marks(buf)
    local git_status = state.get_git_status(buf)

    for _, item in ipairs(entries) do
        local parsed, row = item.entry, item.row
        local change = row_changes[row] or {}
        local original = change.original or st.model.original_by_id[parsed.id]
        local op = change.op
        local abs_path = path.join_abs(root, parsed.fs_name)
        local source_path = original and original.abs_path or abs_path
        local stat = uv.fs_lstat(source_path)
        local icon, hl = icons.get_entry_icon(parsed.name)
        local virt_text = {}

        if stat then
            local perm_str = format_mode(stat.mode)
            if perm_str then
                for i = 1, 9 do
                    local ch = perm_str:sub(i, i)
                    local perm_hl = ch == "r" and "adevFilesPermRead"
                        or ch == "w" and "adevFilesPermWrite"
                        or ch == "x" and "adevFilesPermExec"
                        or "adevFilesPermDash"
                    table.insert(virt_text, { ch, perm_hl })
                end
                table.insert(virt_text, { " ", "Comment" })
            end
        end
        if selection_marks[row] then
            table.insert(virt_text, { "● ", "adevFilesPendingMark" })
        end
        if stat and stat.type == "link" then
            table.insert(virt_text, { "@ ", "adevFilesSymlink" })
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
        local lookup_name = original and original.fs_name or parsed.fs_name
        local gs, gs_hl = git_indicator(git.get_file_status(git_status, lookup_name))
        if gs then
            table.insert(suffix, { "[" .. gs .. "]", gs_hl })
        end

        if op then
            if op.type == "create" then
                table.insert(suffix, { " [new]", "adevFilesPendingNew" })
            elseif op.type == "rename" then
                table.insert(suffix, { " [renamed]", "adevFilesPendingRenamed" })
            elseif op.type == "delete" then
                table.insert(suffix, { " [deleted]", "adevFilesPendingDelete" })
            elseif op.type == "copy" or op.type == "move" then
                local src_rel = path.relpath(root, op.src)
                local label = op.type == "move" and " [moved from " or " [copied from "
                local label_hl = op.type == "move" and "adevFilesPendingMove"
                    or "adevFilesPendingCopy"
                table.insert(suffix, { label .. src_rel .. "]", label_hl })
            end
        end

        local clip_mode = clip_sources[source_path] or (move_sources[source_path] and "move")
        if
            clip_mode
            and (not op or (op.type ~= "delete" and op.type ~= "copy" and op.type ~= "move"))
        then
            table.insert(suffix, {
                clip_mode == "move" and " [moved]" or " [copied]",
                clip_mode == "move" and "adevFilesPendingMove" or "adevFilesPendingCopy",
            })
        end
        if #suffix > 0 then
            vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
                virt_text = suffix,
                virt_text_pos = "eol",
            })
        end
    end

    local summary = listing.summarize(buf, entries, ops or {})
    vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
        virt_text = title_chunks(),
        virt_text_pos = "overlay",
        virt_lines = {
            close_box {
                { "│ root  ", "Comment" },
                { root, "Directory" },
            },
            close_box(summary_chunks(summary)),
            { { "╰" .. string.rep("─", HEADER_WIDTH - 2) .. "╯", "Comment" } },
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
function M.render(buf, root, opts)
    local st = state.get(buf)
    opts = opts or {}
    if st then
        opts.show_hidden = st.show_hidden
    end
    return view.render(buf, root, opts)
end

return M
