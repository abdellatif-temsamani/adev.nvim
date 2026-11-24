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
        "  Reading the listing",
        "    rwx columns: permissions before each entry (rwxr-xr-x style).",
        "    ●: marked entry (TAB / visual selection workflows).",
        "    @: symlink entry.",
        "    ▸ + icon: directory entry; icon: file type (unknown files use generic icon).",
        "    Git suffixes: [M] modified [A] added [D] deleted [R] renamed",
        "                  [C] copied [?] untracked [U] conflict",
        "    [M+]: directory has aggregated descendant git status.",
        "    Pending labels: [new] [renamed] [deleted]",
        "                    [copied from ...] [moved from ...]",
        "                    [copied] [moved] clipboard markers",
        "    Header shows file/dir/pending counts, hidden state, Git counts, or Git n/a.",
        "",
        "  Navigation",
        entry("<CR> / L / <Right>", "open file / enter directory"),
        entry("<BS> / H / <Left>", "parent directory"),
        entry("=", "go to initial root"),
        entry("<leader>nq", "quit"),
        entry("q", "close floating file manager"),
        entry("<leader>nh", "toggle hidden files"),
        entry("<leader>nf", "refresh directory"),
        entry("<leader>ng", "refresh git status"),
        entry("<leader>ne", "jump to next plan error"),
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
        entry("<leader>nX", "clear clipboard"),
        "    Copies may be renamed before saving.",
        "    Cancel a move before renaming/deleting its source.",
        "",
        "  Edits",
        "    Edit names to rename; add lines to create entries.",
        "    Append  #del  to cancel a pasted row or stage delete of a real entry.",
        "    Example: /12 notes.txt  #del  -> staged delete/removed paste row.",
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
        "  Git",
        "    [M]=modified [A]=added [D]=deleted [R]=renamed [C]=copied",
        "    [?]=untracked [U]=conflict [M+]=aggregated directory status",
        "    Git n/a in header means git status is unavailable.",
        "",
        "  Help and popups",
        entry("?", "open this help menu"),
        entry("q / <Esc>", "close help / pending changes popup"),
        entry("j / k / <C-d> / <C-u>", "scroll help / pending changes"),
        entry("gg / G", "jump to top / bottom of popup"),
        entry("q", "close permissions guide when focused"),
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

    local help_win = window.floating_window {
        buf = buf,
        title = "adev-files help [j/k: scroll, gg/G: jump, q/Esc: close]",
        width = width,
        height = math.min(#lines + 2, math.max(1, vim.o.lines - 4), 40),
        wo = { wrap = false, cursorline = true },
    }

    if help_win and vim.api.nvim_win_is_valid(help_win) then
        vim.api.nvim_win_set_cursor(help_win, { 1, 0 })
    end

    local set_keymap = keymaps.buffer(buf)
    set_keymap("n", "q", "<cmd>bwipeout<CR>", { desc = "Close help" })
    set_keymap("n", "<esc>", "<cmd>bwipeout<CR>", { desc = "Close help" })
    set_keymap("n", "j", "j", { desc = "Scroll down" })
    set_keymap("n", "k", "k", { desc = "Scroll up" })
    set_keymap("n", "<C-d>", "<C-d>", { desc = "Scroll half page down" })
    set_keymap("n", "<C-u>", "<C-u>", { desc = "Scroll half page up" })
    set_keymap("n", "gg", "gg", { desc = "Jump to top" })
    set_keymap("n", "G", "G", { desc = "Jump to bottom" })
end

return M
