local utils = require "adev-common.utils"

local config = require "adev-files"
local confirm = require "adev-files.events.confirm"
local parse = require "adev-files.parse"
local plan = require "adev-files.sync.plan"
local roots = require "adev-files.root"
local state = require "adev-files.state"
local sync = require "adev-files.sync"

local M = {}

---@param buf integer
---@param name string
---@return any
local function get_buf_var(buf, name)
    local ok, value = pcall(vim.api.nvim_buf_get_var, buf, name)
    if ok then
        return value
    end
    return nil
end

---@param buf integer
---@return integer|nil
local function manager_win(buf)
    local win = vim.fn.bufwinid(buf)
    if win == -1 then
        return nil
    end
    return win
end

---@param buf integer
---@return integer[], string?
local function find_modified_rows(buf)
    local ops, err = plan.plan_ops(buf)
    if err then
        local st = state.get(buf)
        local rows = st and st.plan_error_rows or {}
        if #rows > 0 then
            local copy = vim.deepcopy(rows)
            table.sort(copy)
            return copy, err
        end
        return {}, err
    end
    local found = {}
    for _, op in ipairs(ops or {}) do
        if op.row then
            found[op.row] = true
        end
    end
    local rows = vim.tbl_keys(found)
    table.sort(rows)
    return rows, nil
end

---@param buf integer
---@param rows integer[]
---@return integer|nil
local function jump_next_row(buf, rows)
    local win = manager_win(buf)
    local cur_row = win and (vim.api.nvim_win_get_cursor(win)[1] - 1) or 0
    for _, row in ipairs(rows) do
        if row > cur_row then
            return row
        end
    end
    return rows[1]
end

---@param buf integer
function M.next_modification(buf)
    local rows, err = find_modified_rows(buf)
    if #rows == 0 then
        if err then
            utils.err_notify(err, "adev-files")
        else
            utils.notify("No modifications", vim.log.levels.INFO, "adev-files")
        end
        return
    end
    local row = jump_next_row(buf, rows)
    local win = manager_win(buf)
    if not win or not row then
        return
    end
    vim.api.nvim_win_set_cursor(win, { row + 1, 0 })
    vim.api.nvim_win_call(win, function()
        vim.cmd "normal! zz"
    end)
    if err then
        utils.err_notify(err, "adev-files")
    end
end

---@param buf integer
---@param rows integer[]
---@return integer|nil
local function jump_prev_row(buf, rows)
    local win = manager_win(buf)
    local cur_row = win and (vim.api.nvim_win_get_cursor(win)[1] - 1) or 0
    for i = #rows, 1, -1 do
        if rows[i] < cur_row then
            return rows[i]
        end
    end
    return rows[#rows]
end

---@param buf integer
function M.prev_modification(buf)
    local rows, err = find_modified_rows(buf)
    if #rows == 0 then
        if err then
            utils.err_notify(err, "adev-files")
        else
            utils.notify("No modifications", vim.log.levels.INFO, "adev-files")
        end
        return
    end
    local row = jump_prev_row(buf, rows)
    local win = manager_win(buf)
    if not win or not row then
        return
    end
    vim.api.nvim_win_set_cursor(win, { row + 1, 0 })
    vim.api.nvim_win_call(win, function()
        vim.cmd "normal! zz"
    end)
    if err then
        utils.err_notify(err, "adev-files")
    end
end

---@param buf integer
function M.next_plan_error(buf)
    local st = state.get(buf)
    if not st then
        return
    end
    plan.plan_ops(buf)
    st = state.get(buf)
    local rows = st and st.plan_error_rows or {}
    if #rows == 0 then
        utils.notify("No plan errors", vim.log.levels.INFO, "adev-files")
        return
    end
    local row = jump_next_row(buf, rows)
    local win = manager_win(buf)
    if not win or not row then
        return
    end
    vim.api.nvim_win_set_cursor(win, { row + 1, 0 })
    vim.api.nvim_win_call(win, function()
        vim.cmd "normal! zz"
    end)
    if st.plan_error then
        utils.err_notify(st.plan_error, "adev-files")
    end
end

--- enter directory under cursor
---@param buf integer
function M.open_or_enter(buf)
    local st = state.get(buf)
    if not st or st.applying or st.confirming then
        return
    end

    local win = manager_win(buf)
    if not win then
        return
    end
    local line = vim.api.nvim_buf_get_lines(
        buf,
        vim.api.nvim_win_get_cursor(win)[1] - 1,
        vim.api.nvim_win_get_cursor(win)[1],
        false
    )[1] or ""
    local entry, err = parse.parse_line(line)
    if err then
        utils.err_notify(err, "adev-files")
        return
    end
    if not entry then
        return
    end

    local original = st.model.original_by_id[entry.id]
    if not original then
        utils.notify("Save changes before opening this entry", vim.log.levels.WARN, "adev-files")
        return
    end
    if original.kind == "directory" then
        local dest = roots.child_root(st.root, original.fs_name)
        confirm.confirm_discard_if_modified(buf, dest, function(ok)
            if not ok then
                return
            end
            local st2 = state.get(buf)
            if not st2 or st2.applying then
                return
            end
            sync.set_root(buf, dest)
        end)
        return
    end

    local cfg = config.get_config() or {}
    local open_files = cfg.open_files or {}
    if not open_files.enabled then
        utils.notify_once(
            "File opening is disabled. Set `core_plugins.adev_files.opts.open_files.enabled = true` to open files with <CR>, or keep browsing directories here.",
            vim.log.levels.INFO,
            "adev-files"
        )
        return
    end

    local method = open_files.method or "edit"
    local path = original.abs_path
    local prev_win = get_buf_var(buf, "adev_files_prev_win")
    local manager_mode = get_buf_var(buf, "adev_files_mode")

    local open_cmd = function()
        local cmd = method
        if cmd ~= "edit" and cmd ~= "split" and cmd ~= "vsplit" and cmd ~= "tabedit" then
            cmd = "edit"
        end
        -- Resolve windows at open time: a stored window ID may have been
        -- reused for an unrelated buffer since this manager was opened.
        local manager_win = vim.fn.bufwinid(buf)
        if manager_win == -1 then
            manager_win = nil
        end
        if
            prev_win
            and (
                not vim.api.nvim_win_is_valid(prev_win)
                or vim.api.nvim_win_get_buf(prev_win) == buf
            )
        then
            prev_win = nil
        end
        if manager_mode == "current" and manager_win then
            vim.api.nvim_set_current_win(manager_win)
        elseif prev_win and vim.api.nvim_win_is_valid(prev_win) then
            vim.api.nvim_set_current_win(prev_win)
        end
        -- nvim_cmd passes the path as a single argument, so names containing
        -- newlines or quotes survive (Ex command strings cannot represent them).
        local opened, open_err = pcall(vim.api.nvim_cmd, { cmd = cmd, args = { path } }, {})
        if not opened then
            utils.err_notify("Cannot open " .. path .. ": " .. tostring(open_err), "adev-files")
            return
        end
        if manager_mode ~= "current" and manager_win and vim.api.nvim_win_is_valid(manager_win) then
            vim.api.nvim_win_close(manager_win, true)
        end
    end

    confirm.confirm_discard_if_modified(buf, path, function(ok)
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
    if not st or st.applying or st.confirming then
        return
    end
    local parent = roots.parent_root(st.root)
    if parent == st.root then
        utils.notify("Already at filesystem root", vim.log.levels.INFO, "adev-files")
        return
    end

    confirm.confirm_discard_if_modified(buf, parent, function(ok)
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
    if not st or st.applying or st.confirming then
        return
    end

    confirm.confirm_discard_if_modified(buf, function(ok)
        if not ok then
            return
        end

        local manager_mode = get_buf_var(buf, "adev_files_mode")
        local ok_var, manager_win = pcall(vim.api.nvim_buf_get_var, buf, "adev_files_win")
        if manager_mode == "current" then
            if ok_var and manager_win and vim.api.nvim_win_is_valid(manager_win) then
                local prev_buf = get_buf_var(buf, "adev_files_prev_buf")
                if prev_buf and vim.api.nvim_buf_is_valid(prev_buf) and prev_buf ~= buf then
                    vim.api.nvim_win_set_buf(manager_win, prev_buf)
                else
                    local empty = vim.api.nvim_create_buf(true, false)
                    vim.api.nvim_win_set_buf(manager_win, empty)
                end
            end
            return
        end

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
    if not st or st.applying or st.confirming or not st.initial_root then
        return
    end
    if st.root == st.initial_root then
        utils.notify("Already at initial root", vim.log.levels.INFO, "adev-files")
        return
    end

    confirm.confirm_discard_if_modified(buf, st.initial_root, function(ok)
        if not ok then
            return
        end
        sync.set_root(buf, st.initial_root)
    end)
end

return M
