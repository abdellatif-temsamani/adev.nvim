local ui = require "adev-common.ui"
local utils = require "adev-common.utils"

local M = {}

function M.create()
    local dir = utils.files.get_dirname() or ""
    local on_create_confirm = require "adev-files.actions.create"
    ui.input("Create a file/dir [trailing / for dir]", {
        default = dir,
        completion = "file",
        title = "adev-files",
    }, on_create_confirm)
end

function M.list()
    require "adev-files.actions.list" ()
end

function M:keymap(key, callback, desc)
    assert(type(callback) == "function", "callback must be a function")

    local keymap_set = vim.keymap.set
    keymap_set("n", "<leader>n" .. key, callback, { noremap = true, silent = true, desc = desc })
end

function M:setup_keymaps()
    self:keymap("a", self.create, "Create file/directory")

    self:keymap("l", self.list, "List files/directories")
end

return M
