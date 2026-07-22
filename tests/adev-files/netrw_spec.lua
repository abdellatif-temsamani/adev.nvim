vim.opt.runtimepath:append(vim.fn.getcwd())

local uv = vim.uv or vim.loop

local function write_file(path, contents)
    local fd = assert(uv.fs_open(path, "w", 420))
    assert(uv.fs_write(fd, contents, 0))
    assert(uv.fs_close(fd))
end

local root = vim.fn.tempname()
assert(vim.fn.mkdir(root, "p") == 1)
write_file(root .. "/child.txt", "content")
write_file(root .. "/previous.txt", "previous")

local ok, err = xpcall(function()
    local adev_files = require "adev-files"
    adev_files.setup {
        open_files = { enabled = true, method = "edit" },
    }

    assert(adev_files.get_config().replace_netrw == true)
    assert(vim.g.loaded_netrw == 1)
    assert(vim.g.loaded_netrwPlugin == 1)

    vim.cmd.edit(vim.fn.fnameescape(root .. "/previous.txt"))
    local previous_buf = vim.api.nvim_get_current_buf()
    vim.cmd.edit(vim.fn.fnameescape(root))

    local buf = vim.api.nvim_get_current_buf()
    assert(vim.bo[buf].filetype == "adev_files")
    assert(vim.bo[buf].buftype == "acwrite")
    assert(vim.api.nvim_buf_get_name(buf):match "^adev%-files://")
    assert(vim.api.nvim_win_get_config(0).relative == "")

    local state = assert(require("adev-files.state").get(buf))
    assert(state.root == require("adev-files.root").normalize_root(root))

    require("adev-files.events.navigation").quit(buf)
    assert(vim.api.nvim_get_current_buf() == previous_buf)
    assert(not vim.api.nvim_buf_is_valid(buf))

    vim.cmd.edit(vim.fn.fnameescape(root))
    buf = vim.api.nvim_get_current_buf()

    local child_row
    for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        if line == "child.txt" then
            child_row = row
            break
        end
    end
    assert(child_row)
    vim.api.nvim_win_set_cursor(0, { child_row, 0 })
    require("adev-files.events.navigation").open_or_enter(buf)

    assert(vim.api.nvim_buf_get_name(0) == root .. "/child.txt")
    assert(not vim.api.nvim_buf_is_valid(buf))
end, debug.traceback)

pcall(vim.cmd, "enew!")
vim.fn.delete(root, "rf")

if not ok then
    error(err)
end

print "netrw replacement test passed"
