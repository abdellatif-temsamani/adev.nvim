vim.opt.runtimepath:append(vim.fn.getcwd())

local uv = vim.uv or vim.loop
local root = vim.fn.tempname()
assert(vim.fn.mkdir(root, "p") == 1)
assert(vim.fn.mkdir(root .. "/target", "p") == 1)
assert(uv.fs_symlink(root .. "/target", root .. "/linked-directory"))

local ok, err = xpcall(function()
    local listing = require "adev-files.file_manager.listing"
    local parse = require "adev-files.parse"
    local lines = listing.build_lines(root)

    assert(vim.tbl_contains(lines, "linked-directory/"))

    local entry = assert(parse.parse_line "linked-directory/")
    assert(entry.kind == "directory")
    assert(entry.fs_name == "linked-directory")
end, debug.traceback)

vim.fn.delete(root, "rf")

if not ok then
    error(err)
end

print "symlink directory listing test passed"
