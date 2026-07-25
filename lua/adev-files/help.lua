local keymaps = require "adev-common.utils.keymaps"
local window = require "adev-common.ui.window"

local M = {}

---@return string[]
local function content()
    local entry = function(key, desc)
        return "    " .. key .. string.rep(" ", 22 - #key) .. desc
    end

    local lines = {
        "  adev-files",
        "",
        "  Navigation",
        entry("<CR> / L", "open file / enter directory"),
        entry("<bs> / H", "parent directory"),
        entry("=", "go to initial root"),
        entry("<leader>nq", "quit"),
        entry("<leader>nh", "toggle hidden files"),
        "",
        "  Selection",
        entry("<TAB>", "toggle mark on current line"),
        entry("<leader>nm", "clear all marks"),
        "",
        "  Clipboard",
        entry("<leader>ny", "copy (normal/visual)"),
        entry("<leader>nx", "cut/move (normal/visual)"),
        entry("<leader>np", "paste (at cursor)"),
        "",
        "  Edits",
        entry("<leader>bs", "apply edits"),
        entry("<leader>nu", "revert current line"),
        entry("<leader>nc", "reset all (discard changes)"),
        "",
        "  Delete",
        entry("<leader>nd", "delete (normal/visual)"),
        "",
        "  Global",
        entry("<leader>no", "open file manager"),
        entry("<leader>na", "create file"),
        entry("<leader>nr", "rename file"),
        entry("<leader>nd", "delete file"),
        "",
        "  Confirm",
        entry("y / <CR>", "confirm"),
        entry("n / q / <Esc>", "cancel"),
    }
    return lines
end

function M.open()
    local buf = vim.api.nvim_create_buf(false, true)
    if not buf then
        return
    end

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true
    vim.bo[buf].filetype = "adev_files_help"

    local lines = content()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    window.floating_window {
        buf = buf,
        title = "adev-files help [q: close]",
        width = 64,
        height = math.min(#lines + 2, 28),
        wo = { wrap = false },
    }

    local set_keymap = keymaps.buffer(buf)
    set_keymap("n", "q", "<cmd>bwipeout<CR>")
    set_keymap("n", "<esc>", "<cmd>bwipeout<CR>")
end

return M
