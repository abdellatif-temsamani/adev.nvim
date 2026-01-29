local utils = require "adev-common.utils"

local confirm = require "adev-files.events.confirm"
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
    if not entry or entry.kind ~= "directory" then
        return
    end

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
