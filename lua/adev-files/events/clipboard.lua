local utils = require "adev-common.utils"

local clipboard = require "adev-files.clipboard"
local selection = require "adev-files.events.selection"
local parse = require "adev-files.parse"
local state = require "adev-files.state"
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
                rows[root .. entry.fs_name] = i - 1
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
    local items = selection.collect_entries(buf)
    if #items == 0 then
        return
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

    local ops = {}
    local row_by_abs = build_row_by_abs(buf, st.root)
    local mark_rows = {}
    if clip.mode == "move" then
        for _, item in ipairs(clip.items) do
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
    local pending_ns = state.pending_ns()
    local insert_at = vim.api.nvim_buf_line_count(buf)
    for _, item in ipairs(clip.items) do
        local src = (item.src or ""):gsub("/+$", "")
        local base = vim.fs.basename(src)
        local dst = unique_dest(dest_root, base, existing_abs)

        local rel = relpath(st.root, dst)
        if item.kind == "directory" and rel:sub(-1) ~= "/" then
            rel = rel .. "/"
        end
        vim.api.nvim_buf_set_lines(buf, insert_at, insert_at, false, { rel })
        local mark_id = vim.api.nvim_buf_set_extmark(buf, pending_ns, insert_at, 0, { right_gravity = false })
        insert_at = insert_at + 1

        existing_abs[dst] = true
        table.insert(ops, { type = clip.mode, src = item.src, dst = dst, mark_id = mark_id })
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
