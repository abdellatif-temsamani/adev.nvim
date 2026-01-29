local clipboard = require "adev-files.events.clipboard"
local delete = require "adev-files.events.delete"
local help = require "adev-files.help"
local nav = require "adev-files.events.navigation"
local parse = require "adev-files.parse"
local utils = require "adev-common.utils"

local M = {}

---@param buf integer
function M.attach(buf)
    ---Set a the buffer local keymap.
    ---@param modes string|string[] Mode(s) in which the mapping applies.
    ---@param lhs string            Left-hand side of the mapping (key sequence).
    ---@param rhs string|function   Right-hand side action or callback.
    local set_keymap = function(modes, lhs, rhs)
        vim.keymap.set(modes, lhs, rhs, { buffer = buf })
    end

    set_keymap("n", "<cr>", function()
        nav.open_or_enter(buf)
    end)
    set_keymap("n", "L", function()
        nav.open_or_enter(buf)
    end)
    set_keymap("n", "<right>", function()
        nav.open_or_enter(buf)
    end)
    set_keymap("n", "H", function()
        nav.go_parent(buf)
    end)
    set_keymap("n", "<bs>", function()
        nav.go_parent(buf)
    end)
    set_keymap("n", "<left>", function()
        nav.go_parent(buf)
    end)

    set_keymap({ "n", "x" }, "yy", function()
        clipboard.set_clipboard(buf, "copy")
    end)
    set_keymap({ "n", "x" }, "dd", function()
        clipboard.set_clipboard(buf, "move")
    end)
    set_keymap({ "n", "x" }, "X", function()
        delete.delete_selected(buf)
    end)

    set_keymap("n", "?", function()
        help.open()
    end)

    set_keymap("n", "P", function()
        local entry, err = parse.parse_line(vim.api.nvim_get_current_line())
        if err then
            utils.err_notify(err, "adev-files")
            return
        end

        if entry and entry.kind == "directory" then
            clipboard.paste(buf, entry.fs_name)
            return
        end

        clipboard.paste(buf, "")
    end)

    set_keymap("n", "yc", function()
        clipboard.clear(buf)
    end)
end

return M
