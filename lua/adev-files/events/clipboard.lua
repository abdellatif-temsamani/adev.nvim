local utils = require "adev-common.utils"

local clipboard = require "adev-files.clipboard"
local selection = require "adev-files.events.selection"
local state = require "adev-files.state"
local sync = require "adev-files.sync"
local validate = require "adev-files.events.validate"

local M = {}

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
    utils.notify(string.format("%s %d item(s)", mode == "copy" and "Copied" or "Cut", #items), vim.log.levels.INFO, "adev-files")
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
    for _, item in ipairs(clip.items) do
        local base = vim.fs.basename(item.src)
        local dst = dest_root .. base
        if utils.files.file_exists(dst) then
            utils.err_notify("target exists: " .. dst, "adev-files")
            return
        end
        table.insert(ops, { type = clip.mode, src = item.src, dst = dst })
    end

    local opts = {
        title = "adev-files",
        on_success = function()
            if clip.mode == "move" then
                clipboard.clear()
            end
        end,
    }
    if vim.bo[buf].modified then
        opts.preface = { "Note: the view has unsaved edits; confirming will discard them." }
    end
    sync.apply_ops_with_confirm(buf, ops, opts)
end

---@param buf integer
function M.clear(buf)
    clipboard.clear()
    utils.notify("Clipboard cleared", vim.log.levels.INFO, "adev-files")
    refresh_keep_cursor(buf)
end

return M
