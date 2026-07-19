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

    -- Render header + entries on first open
    render.render(buf, root)

    -- avoid E32 and make buffer identity stable
    vim.api.nvim_buf_set_name(buf, "adev-files://" .. root)

    -- keep this lazy to avoid require cycles
    require("adev-files.events").register(buf, root)

    -- Prefer a taller window to allow editing/adding many entries.
    local max_height = math.max(3, vim.o.lines - 4)
    local header_offset = 4 -- help, separator, root, blank
    local height = math.min(math.max(#lines + header_offset, 12), max_height)
    win.create_win(buf, height, 72, root)

    local manager_win = vim.api.nvim_get_current_win()
    pcall(vim.api.nvim_buf_set_var, buf, "adev_files_prev_win", prev_win)
    pcall(vim.api.nvim_buf_set_var, buf, "adev_files_win", manager_win)

    -- Try to position cursor on the file that was active before opening
    local target_row = 1
    local ok_prev, prev_buf = pcall(vim.api.nvim_win_get_buf, prev_win)
    if ok_prev and prev_buf and vim.api.nvim_buf_is_valid(prev_buf) then
        local buf_name = vim.api.nvim_buf_get_name(prev_buf)
        if buf_name ~= "" then
            local fname = vim.fn.fnamemodify(buf_name, ":t")
            if fname ~= "" then
                local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                for i, line in ipairs(buf_lines) do
                    local stripped = line:gsub("/$", "")
                    if stripped == fname then
                        target_row = i
                        break
                    end
                end
            end
        end
    end
    pcall(vim.api.nvim_win_set_cursor, 0, { target_row, 0 })
end

return M
