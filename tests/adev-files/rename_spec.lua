vim.opt.runtimepath:append(vim.fn.getcwd())
vim.opt.swapfile = false

local uv = vim.uv or vim.loop

local function write_file(path, contents)
    local fd = assert(uv.fs_open(path, "w", 420))
    assert(uv.fs_write(fd, contents, 0))
    assert(uv.fs_close(fd))
end

local root = vim.fn.tempname()
assert(vim.fn.mkdir(root, "p") == 1)

local source = root .. "/source.lua"
local destination = root .. "/renamed.lua"
write_file(source, "original\n")

local original_input = vim.ui.input
local original_notify = vim.notify

local ok, err = xpcall(function()
    vim.cmd.edit(vim.fn.fnameescape(source))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "edited before rename" })
    assert(vim.bo.modified)

    vim.ui.input = function(_, callback)
        callback "renamed.lua"
    end
    vim.notify = function() end

    require("adev-files").rename_file()

    assert(uv.fs_stat(source) == nil)
    assert(uv.fs_stat(destination) ~= nil)
    assert(vim.api.nvim_buf_get_name(0) == destination)
    assert(not vim.bo.modified)
    assert(vim.fn.readfile(destination)[1] == "edited before rename")

    -- A normal write after the rename must not produce E13 or an overwrite
    -- confirmation.
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "edited after rename" })
    vim.cmd.write()
    assert(vim.fn.readfile(destination)[1] == "edited after rename")
end, debug.traceback)

vim.ui.input = original_input
vim.notify = original_notify
pcall(vim.cmd, "bwipeout!")
vim.fn.delete(root, "rf")

if not ok then
    error(err)
end

print "rename modified buffer test passed"
