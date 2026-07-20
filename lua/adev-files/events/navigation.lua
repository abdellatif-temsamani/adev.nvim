local utils = require "adev-common.utils"

local confirm = require "adev-files.events.confirm"
local config = require "adev-files"
local parse = require "adev-files.parse"
local roots = require "adev-files.root"
local state = require "adev-files.state"
local view = require "adev-files.core.view"

local M = {}

---@param buf integer
---@param row integer
---@param entry AdevFilesEntry|nil
---@param deleted boolean
---@param original_lines table<integer, {entry: AdevFilesEntry, abs_path: string}>
---@return boolean
local function is_modified_row(row, entry, deleted, original_lines)
    if deleted then
        return true
    end
    local orig = original_lines[row]
    if not orig then
        return entry ~= nil
    end
    if not entry then
        return true
    end
    return entry.fs_name ~= orig.entry.fs_name
end

---@param buf integer
---@return integer[], string?
local function find_modified_rows(buf)
    local st = state.get(buf)
    if not st then
        return {}, "missing state"
    end
    local entries, err = view.parse_buffer(buf)
    if err then
        return {}, err
    end
    local original_lines = state.get_original_lines(buf)
    local rows = {}
    for _, item in ipairs(entries) do
        if is_modified_row(item.row, item.entry, item.deleted, original_lines) then
            table.insert(rows, item.row)
        end
    end
    return rows, nil
end

---@param buf integer
function M.next_modification(buf)
    local rows, err = find_modified_rows(buf)
    if err then
        utils.err_notify(err, "adev-files")
        return
    end
    if #rows == 0 then
        utils.notify("No modifications", vim.log.levels.INFO, "adev-files")
        return
    end
    local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    for _, row in ipairs(rows) do
        if row > cur_row then
            vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
            return
        end
    end
    vim.api.nvim_win_set_cursor(0, { rows[1] + 1, 0 })
end

---@param buf integer
function M.prev_modification(buf)
    local rows, err = find_modified_rows(buf)
    if err then
        utils.err_notify(err, "adev-files")
        return
    end
    if #rows == 0 then
        utils.notify("No modifications", vim.log.levels.INFO, "adev-files")
        return
    end
    local cur_row = vim.api.nvim_win_get_cursor(0)[1] - 1
    for i = #rows, 1, -1 do
        if rows[i] < cur_row then
            vim.api.nvim_win_set_cursor(0, { rows[i] + 1, 0 })
            return
        end
    end
    vim.api.nvim_win_set_cursor(0, { rows[#rows] + 1, 0 })
end

--- enter directory under cursor
---@param buf integer
function M.open_or_enter(buf)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end

    local entry, err = parse.parse_line(vim.api.nvim_get_current_line())
    if err then
        utils.err_notify(err, "adev-files")
        return
    end
    if not entry then
        return
    end

    if entry.kind == "directory" then
        confirm.confirm_discard_if_modified(buf, function(ok)
            if not ok then
                return
            end
            local st2 = state.get(buf)
            if not st2 or st2.applying then
                return
            end
            sync.set_root(buf, roots.child_root(st2.root, entry.fs_name))
        end)
        return
    end

    local cfg = config.get_config() or {}
    local open_files = cfg.open_files or {}
    if not open_files.enabled then
        return
    end

    local method = open_files.method or "edit"
    local path = roots.normalize_root(st.root) .. entry.fs_name
    local get_buf_var = function(name)
        local ok, value = pcall(vim.api.nvim_buf_get_var, buf, name)
        if ok then
            return value
        end
        return nil
    end
    local prev_win = get_buf_var("adev_files_prev_win")
    local manager_win = get_buf_var("adev_files_win")

    local open_cmd = function()
        local cmd = method
        if cmd ~= "edit" and cmd ~= "split" and cmd ~= "vsplit" and cmd ~= "tabedit" then
            cmd = "edit"
        end
        if prev_win and vim.api.nvim_win_is_valid(prev_win) then
            vim.api.nvim_set_current_win(prev_win)
        end
        vim.cmd(cmd .. " " .. vim.fn.fnameescape(path))
        if manager_win and vim.api.nvim_win_is_valid(manager_win) then
            vim.api.nvim_win_close(manager_win, true)
        end
    end

    confirm.confirm_discard_if_modified(buf, function(ok)
        if not ok then
            return
        end
        open_cmd()
    end)
end

--- go to parent directory
---@param buf integer
function M.go_parent(buf)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end
    local parent = roots.parent_root(st.root)
    if parent == st.root then
        return
    end

    confirm.confirm_discard_if_modified(buf, function(ok)
        if not ok then
            return
        end
        sync.set_root(buf, parent)
    end)
end

--- quit file manager
---@param buf integer
function M.quit(buf)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end

    confirm.confirm_discard_if_modified(buf, function(ok)
        if not ok then
            return
        end

        local ok_var, manager_win = pcall(vim.api.nvim_buf_get_var, buf, "adev_files_win")
        if ok_var and manager_win then
            local ok_win, is_valid = pcall(vim.api.nvim_win_is_valid, manager_win)
            if ok_win and is_valid then
                pcall(vim.api.nvim_win_close, manager_win, true)
            end
        end

        for _, win_id in ipairs(vim.fn.win_findbuf(buf)) do
            if manager_win and win_id == manager_win then
                goto continue
            end
            local ok_win, is_valid = pcall(vim.api.nvim_win_is_valid, win_id)
            if ok_win and is_valid then
                pcall(vim.api.nvim_win_close, win_id, true)
            end
            ::continue::
        end
    end)
end

--- go to initial root directory
---@param buf integer
function M.go_root(buf)
    local st = state.get(buf)
    if not st or st.applying or not st.initial_root then
        return
    end
    if st.root == st.initial_root then
        return
    end

    confirm.confirm_discard_if_modified(buf, function(ok)
        if not ok then
            return
        end
        sync.set_root(buf, st.initial_root)
    end)
end

return M
