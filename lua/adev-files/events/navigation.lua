local utils = require "adev-common.utils"

local confirm = require "adev-files.events.confirm"
local config = require "adev-files"
local parse = require "adev-files.parse"
local roots = require "adev-files.file_manager.roots"
local state = require "adev-files.state"
local sync = require "adev-files.sync"

local M = {}

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

    local cfg = config.get_config()
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

return M
