local utils = require "adev-common.utils"

local clipboard = require "adev-files.clipboard"
local selection = require "adev-files.events.selection"
local parse = require "adev-files.parse"
local state = require "adev-files.state"
local marks = require "adev-files.core.marks"
local path = require "adev-files.utils.fs.path"
local sync = require "adev-files.sync"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local validate = require "adev-files.events.validate"

local M = {}

---@param name string
---@return string, string
local function split_name_ext(name)
    local dot = name:match("^.*()%.")
    if not dot or dot == 1 then
        return name, ""
    end
    return name:sub(1, dot - 1), name:sub(dot)
end


---@param buf integer
---@param root string
---@return table<string, boolean>
local function build_existing_abs(buf, root)
    local existing = {}
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for _, line in ipairs(lines) do
        local clean, is_deleted = parse.strip_delete_marker(line)
        if not is_deleted then
            local entry = select(1, parse.parse_line(clean))
            if entry then
                existing[root .. entry.fs_name] = true
            end
        end
    end
    return existing
end

---@param buf integer
---@param root string
---@return table<string, integer>
local function build_row_by_abs(buf, root)
    local rows = {}
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i, line in ipairs(lines) do
        local clean, is_deleted = parse.strip_delete_marker(line)
        if not is_deleted then
            local entry = select(1, parse.parse_line(clean))
            if entry then
                rows[vim.fn.fnamemodify(root .. entry.fs_name, ":p")] = i - 1
            end
        end
    end
    return rows
end

---@param dest_root string
---@param base string
---@param existing_abs table<string, boolean>
---@return string
local function unique_dest(dest_root, base, existing_abs)
    local candidate = dest_root .. base
    if not utils.files.file_exists(candidate) and not existing_abs[candidate] then
        return candidate
    end

    local name, ext = split_name_ext(base)
    local i = 1
    while true do
        local next_base = string.format("%s_%d%s", name, i, ext)
        local next_dst = dest_root .. next_base
        if not utils.files.file_exists(next_dst) and not existing_abs[next_dst] then
            return next_dst
        end
        i = i + 1
    end
end

---@param buf integer
local function refresh_keep_cursor(buf)
    local ok, cur = pcall(vim.api.nvim_win_get_cursor, 0)
    sync.refresh(buf)
    if ok and cur and vim.api.nvim_buf_is_valid(buf) then
        local last = vim.api.nvim_buf_line_count(buf)
        local row = math.max(1, math.min(cur[1], last))
        pcall(vim.api.nvim_win_set_cursor, 0, { row, cur[2] })
    end
end

---@param buf integer
---@param mode 'copy'|'move'
function M.set_clipboard(buf, mode)
    local items, skipped = selection.collect_entries(buf)
    if #items == 0 then
        if skipped and skipped > 0 then
            utils.err_notify(
                string.format("Cannot %s non-existent entries", mode == "copy" and "copy" or "move"),
                "adev-files"
            )
        end
        return
    end
    if skipped and skipped > 0 then
        utils.notify(
            string.format("Skipped %d non-existent entr%s", skipped, skipped == 1 and "y" or "ies"),
            vim.log.levels.INFO,
            "adev-files"
        )
    end
    clipboard.set(mode, items)
    utils.notify(
        string.format("%s %d item(s)", mode == "copy" and "Copied" or "Cut", #items),
        vim.log.levels.INFO,
        "adev-files"
    )
    refresh_keep_cursor(buf)
end

---@param buf integer
---@param rel_dir string
function M.paste(buf, rel_dir)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end

    local clip = clipboard.get()
    if not clip or not clip.items or #clip.items == 0 then
        utils.notify("Clipboard empty", vim.log.levels.INFO, "adev-files")
        return
    end

    local ok_dir, cleaned = validate.validate_rel_dir(rel_dir or "")
    if not ok_dir then
        utils.err_notify(cleaned or "invalid destination", "adev-files")
        return
    end

    local dest_root = st.root
    if cleaned ~= "" then
        if cleaned:sub(-1) ~= "/" then
            cleaned = cleaned .. "/"
        end
        dest_root = dest_root .. cleaned
    end

    local items = clip.items
    if clip.mode == "move" then
        local dest_root_abs = vim.fn.fnamemodify(dest_root, ":p")
        if dest_root_abs:sub(-1) ~= "/" then
            dest_root_abs = dest_root_abs .. "/"
        end
        local filtered = {}
        local skipped = 0
        for _, item in ipairs(items) do
            local src = (item.src or ""):gsub("/+$", "")
            local parent = vim.fn.fnamemodify(src, ":h")
            if parent:sub(-1) ~= "/" then
                parent = parent .. "/"
            end
            if parent == dest_root_abs then
                skipped = skipped + 1
            else
                table.insert(filtered, item)
            end
        end
        if #filtered == 0 then
            utils.err_notify("Cannot move into same directory", "adev-files")
            return
        end
        if skipped > 0 then
            utils.notify(
                string.format("Skipped %d same-directory entr%s", skipped, skipped == 1 and "y" or "ies"),
                vim.log.levels.INFO,
                "adev-files"
            )
        end
        items = filtered
    end

    local ops = {}
    local row_by_abs = build_row_by_abs(buf, st.root)
    local mark_rows = {}
    if clip.mode == "move" then
        for _, item in ipairs(items) do
            local row = row_by_abs[item.src]
            if row ~= nil then
                mark_rows[row] = true
            end
        end
    end

    for row, _ in pairs(mark_rows) do
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ""
        local marked = parse.mark_delete(line)
        vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { marked })
    end

    local existing_abs = build_existing_abs(buf, st.root)
    local insert_at = vim.api.nvim_buf_line_count(buf)
    for _, item in ipairs(items) do
        local src = (item.src or ""):gsub("/+$", "")
        local base = vim.fs.basename(src)
        local dst = unique_dest(dest_root, base, existing_abs)

        local rel = path.relpath(st.root, dst)
        if item.kind == "directory" and rel:sub(-1) ~= "/" then
            rel = rel .. "/"
        end
        vim.api.nvim_buf_set_lines(buf, insert_at, insert_at, false, { rel })
        local dst_id = marks.ensure_row(buf, insert_at)
        insert_at = insert_at + 1

        existing_abs[dst] = true
        table.insert(ops, { type = clip.mode, src = item.src, dst = dst, dst_id = dst_id, kind = item.kind })
    end

    if #ops == 0 then
        return
    end

    plan.stage_ops(buf, ops)
    render.add_virtual_text(buf, st.root)
end

---@param buf integer
function M.clear(buf)
    clipboard.clear()
    utils.notify("Clipboard cleared", vim.log.levels.INFO, "adev-files")
    refresh_keep_cursor(buf)
end

return M
