local utils = require "adev-common.utils"

local listing = require "adev-files.file_manager.listing"
local render = require "adev-files.file_manager.render"
local roots = require "adev-files.file_manager.roots"
local win = require "adev-files.file_manager.window"

local M = {}

function M.open()
    local prev_win = vim.api.nvim_get_current_win()
    local root = utils.files.get_dirname()
    root = roots.normalize_root(root)
    local lines = listing.build_lines(root)

    local buf = utils.buffers.create(lines, {
        scratch = false,
        listed = false,
        bo = {
            filetype = "adev_files",
            buftype = "acwrite",
            modifiable = true,
            swapfile = false,
            bufhidden = "wipe",
        },
    })

    -- Add virtual text for header and icons
    render.add_virtual_text(buf, root)

    -- avoid E32 and make buffer identity stable
    vim.api.nvim_buf_set_name(buf, "adev-files://" .. root)

    -- keep this lazy to avoid require cycles
    require("adev-files.events").register(buf, root)

    -- Prefer a taller window to allow editing/adding many entries.
    local max_height = math.max(3, vim.o.lines - 4)
    local height = math.min(math.max(#lines, 12), max_height)
    win.create_win(buf, height, 72)

    local manager_win = vim.api.nvim_get_current_win()
    pcall(vim.api.nvim_buf_set_var, buf, "adev_files_prev_win", prev_win)
    pcall(vim.api.nvim_buf_set_var, buf, "adev_files_win", manager_win)

    -- Position cursor at first file entry (line 1)
    pcall(vim.api.nvim_win_set_cursor, 0, { 1, 0 })
end

return M
