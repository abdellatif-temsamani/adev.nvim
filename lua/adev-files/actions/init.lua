local utils = require("adev-files.utils")
local on_create_confirm = require("adev-files.actions.create")

local M = {
    cwd = vim.fn.getcwd(),
}

function M.create()
    local dir = utils.get_basepath(M.cwd) or "" -- starting point
    utils.input("Create a file/dir [trailing / for dir]", dir, "file", on_create_confirm)
end

function M:setup_keymaps()
    local keymap_set = vim.keymap.set

    keymap_set("n", "<leader>na", self.create, { noremap = true, silent = true, desc = "move 1 line down" })
end

return M
