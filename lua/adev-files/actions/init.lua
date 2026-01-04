local on_create_confirm = require "adev-files.actions.create"
local ui = require "adev-common.ui"
local utils = require "adev-common.utils"

local M = {
    cwd = vim.fn.getcwd(),
}

function M.create()
    local dir = utils.files.get_dirname(M.cwd) or "" -- starting point
    ui.input("Create a file/dir [trailing / for dir]", {
        default = dir,
        completion = "file",
        title = "adev-files",
    }, on_create_confirm)
end

function M:setup_keymaps()
    local keymap_set = vim.keymap.set

    keymap_set(
        "n",
        "<leader>na",
        self.create,
        { noremap = true, silent = true, desc = "Create file/directory" }
    )
end

return M
