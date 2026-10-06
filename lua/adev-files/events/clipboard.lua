local fs = require "adev-files.utils.fs"
local utils = require "adev-common.utils"

local clipboard = require "adev-files.clipboard"
local marks = require "adev-files.core.marks"
local parse = require "adev-files.parse"
local path = require "adev-files.utils.fs.path"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local selection = require "adev-files.events.selection"
local state = require "adev-files.state"
local validate = require "adev-files.events.validate"

local M = {}

---@param name string
---@return string, string
local function split_name_ext(name)
    local dot = name:match "^.*()%."
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
                existing[path.join_abs(root, entry.fs_name)] = true
            end
        end
    end
    return existing
end

---@param dest_root string
---@param base string
---@param existing_abs table<string, boolean>
---@return string
local function unique_dest(dest_root, base, existing_abs)
    local candidate = path.join_abs(dest_root, base)
    if not fs.exists(candidate) and not existing_abs[candidate] then
        return candidate
    end

    local name, ext = split_name_ext(base)
    local i = 1
    local max_attempts = 10000
    while i <= max_attempts do
        local next_base = string.format("%s_%d%s", name, i, ext)
        local next_dst = path.join_abs(dest_root, next_base)
        if not fs.exists(next_dst) and not existing_abs[next_dst] then
            return next_dst
        end
        i = i + 1
    end
    return path.join_abs(dest_root, base)
end

---@param buf integer
local function refresh_virtual_text(buf)
    local st = state.get(buf)
    if st then
        render.add_virtual_text(buf, st.root)
    end
end

---@param buf integer
---@param mode 'copy'|'move'
function M.set_clipboard(buf, mode)
    local st = state.get(buf)
    if not st or st.applying or st.confirming or st.needs_refresh then
        return
    end
    local items, skipped, err = selection.collect_entries(buf)
    if err then
        utils.err_notify(err, "adev-files")
        return
    end
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
    refresh_virtual_text(buf)
end

---@param buf integer
---@param rel_dir string
function M.paste(buf, rel_dir)
    local st = state.get(buf)
    if not st or st.applying or st.confirming or st.needs_refresh then
        return
    end

    local clip = clipboard.get()
    if not clip or not clip.items or #clip.items == 0 then
        utils.notify("Clipboard empty", vim.log.levels.INFO, "adev-files")
        return
    end

    -- A clipboard captured before an edit must obey the same source rules.
    for _, item in ipairs(clip.items) do
        if not item.src or not fs.exists(item.src) then
            utils.err_notify(
                "Clipboard source no longer exists: " .. tostring(item.src),
                "adev-files"
            )
            return
        end
    end
    for _, source_buf in ipairs(vim.api.nvim_list_bufs()) do
        local source_state = state.get(source_buf)
        if source_state and vim.api.nvim_buf_is_valid(source_buf) then
            local source_ops = plan.plan_ops(source_buf)
            for _, op in ipairs(source_ops or {}) do
                if op.type == "rename" then
                    for _, item in ipairs(clip.items) do
                        if path.is_same_or_subpath(op.src, item.src) then
                            utils.err_notify(
                                "Save or revert the pending rename before copying or cutting",
                                "adev-files"
                            )
                            return
                        end
                    end
                end
            end
        end
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
        local dest_root_abs = path.abs(dest_root) .. "/"
        local filtered = {}
        local skipped = 0
        for _, item in ipairs(items) do
            local src = path.abs(item.src or "")
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
                string.format(
                    "Skipped %d same-directory entr%s",
                    skipped,
                    skipped == 1 and "y" or "ies"
                ),
                vim.log.levels.INFO,
                "adev-files"
            )
        end
        items = filtered
    end

    local ops = {}
    local existing_abs = build_existing_abs(buf, st.root)
    local insert_at = vim.api.nvim_win_get_cursor(0)[1]
    for _, item in ipairs(items) do
        local src = path.abs(item.src or "")
        local base = vim.fs.basename(src)
        local dst = unique_dest(dest_root, base, existing_abs)

        local rel = path.relpath(st.root, dst)
        rel = parse.format_name(rel)
        if item.kind == "directory" and rel:sub(-1) ~= "/" then
            rel = rel .. "/"
        end
        vim.api.nvim_buf_set_lines(buf, insert_at, insert_at, false, { rel })
        local dst_id = marks.ensure_row(buf, insert_at)
        insert_at = insert_at + 1

        existing_abs[dst] = true
        table.insert(
            ops,
            { type = clip.mode, src = src, dst = dst, dst_id = dst_id, kind = item.kind }
        )
    end

    if #ops == 0 then
        return
    end

    plan.stage_ops(buf, ops)
    state.clear_selection_marks(buf)
    render.add_virtual_text(buf, st.root)
end

---@param buf integer
function M.clear(buf)
    clipboard.clear()
    utils.notify("Clipboard cleared", vim.log.levels.INFO, "adev-files")
    refresh_virtual_text(buf)
end

return M
