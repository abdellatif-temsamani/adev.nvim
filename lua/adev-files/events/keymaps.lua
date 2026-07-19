local clipboard = require "adev-files.events.clipboard"
local delete = require "adev-files.events.delete"
local revert = require "adev-files.events.revert"
local help = require "adev-files.help"
local nav = require "adev-files.events.navigation"
local parse = require "adev-files.parse"
local sync_view = require "adev-files.sync.view"
local utils = require "adev-common.utils"

local M = {}

---@param buf integer
function M.attach(buf)
    local set_keymap = utils.keymaps.buffer(buf)

    set_keymap("n", "<cr>", function()
        nav.open_or_enter(buf)
    end)

    set_keymap("n", "K", "<nop>")
    set_keymap("n", "J", "<nop>")
    set_keymap("n", "dd", "<nop>")
    set_keymap("n", "yy", "<nop>")
    set_keymap("n", "D", "<nop>")
    set_keymap("n", "<leader>bq", "<nop>")
    set_keymap("n", "<leader>bs", function()
        vim.cmd "write"
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

    set_keymap("n", "=", function()
        nav.go_root(buf)
    end)
    set_keymap("n", "<leader>nq", function()
        nav.quit(buf)
    end)

    set_keymap("n", "<leader>nh", function()
        sync_view.toggle_hidden(buf)
    end)

    set_keymap({ "n", "x" }, "<leader>ny", function()
        clipboard.set_clipboard(buf, "copy")
    end)
    set_keymap({ "n", "x" }, "<leader>nx", function()
        clipboard.set_clipboard(buf, "move")
    end)
    set_keymap({ "n", "x" }, "<leader>nd", function()
        delete.delete_selected(buf)
    end)

    set_keymap("n", "<leader>nu", function()
        revert.revert_current_line(buf)
    end)

    set_keymap("n", "<leader>nc", function()
        sync_view.discard_reset(buf)
    end)

    set_keymap("n", "?", function()
        help.open()
    end)

    set_keymap("n", "<leader>np", function()
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

end

return M
