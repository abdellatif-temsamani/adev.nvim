local keymaps = require "adev-common.utils.keymaps"
local window = require "adev-common.ui.window"

local M = {}

---@return string[]
local function content()
    local entry = function(key, desc)
        return "    " .. key .. string.rep(" ", math.max(2, 26 - #key)) .. desc
    end

    local lines = {
        "  adev-files",
        "",
        "  Navigation",
        entry("<CR> / L / <Right>", "open file / enter directory"),
        entry("<BS> / H / <Left>", "parent directory"),
        entry("=", "go to initial root"),
        entry("<leader>nq", "quit"),
        entry("q", "close floating file manager"),
        entry("<leader>nh", "toggle hidden files"),
        "",
        "  Selection",
        entry("<TAB>", "toggle mark on current line"),
        entry("<leader>nm", "clear all marks"),
        entry("v / V / <C-v>", "character / line / block selection"),
        "",
        "  Clipboard",
        entry("<leader>ny", "copy current / marked / visual entries"),
        entry("<leader>nx", "cut current / marked / visual entries"),
        entry("<leader>np", "paste into current directory"),
        "",
        "  Edits",
        "    Edit names to rename; add lines to create entries.",
        entry("<leader>bs / :write", "apply staged changes"),
        entry("<leader>nu", "revert current line"),
        entry("<leader>nc", "reset all (discard changes)"),
        entry("<leader>nj", "jump to next changed entry"),
        entry("<leader>nk", "jump to previous changed entry"),
        entry("<leader>ns", "view pending changes"),
        "",
        "  Delete",
        entry("<leader>nd", "stage delete (current / marked / visual)"),
        "",
        "  Permissions",
        entry("<leader>nz", "change permissions (current / marked)"),
        "    Enter 755 or rwxr-xr-x; applies immediately.",
        "",
        "  Global (outside file manager)",
        entry("<leader>no", "open file manager"),
        entry("<leader>na", "create file / directory (prompt)"),
        entry("<leader>nr", "rename current file (prompt)"),
        entry("<leader>nd", "delete current file (confirm)"),
        "    <leader>no, <leader>na and <leader>nr are disabled inside.",
        "",
        "  Confirm",
        entry("y / <CR>", "confirm"),
        entry("n / q / <Esc>", "cancel"),
        "",
        "  Help and popups",
        entry("?", "open this help menu"),
        entry("q / <Esc>", "close help / pending changes popup"),
        entry("q", "close permissions guide when focused"),
        entry("j / k / <C-d> / <C-u>", "scroll help / pending changes"),
        "",
        "  Disabled in file manager",
        entry("u / <C-r>", "use <leader>nu / <leader>nc to revert"),
        entry("K / J", "disabled"),
        entry("dd / D", "use <leader>nd to stage delete"),
        entry("yy", "use <leader>ny to copy"),
        entry("<leader>bq", "use <leader>nq to quit"),
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
    local width = 64
    for _, line in ipairs(lines) do
        width = math.max(width, #line + 2)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    window.floating_window {
        buf = buf,
        title = "adev-files help [j/k: scroll, q/Esc: close]",
        width = width,
        height = math.min(#lines + 2, math.max(1, vim.o.lines - 4), 40),
        wo = { wrap = false },
    }

    local set_keymap = keymaps.buffer(buf)
    set_keymap("n", "q", "<cmd>bwipeout<CR>")
    set_keymap("n", "<esc>", "<cmd>bwipeout<CR>")
end

return M
