local M = {}

function M.create()
    require "adev-files.actions.create" ()
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
