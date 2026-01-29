local window = require "adev-common.ui.window"

local M = {}

--- Compact help content for the help bar above file manager
---@return string[]
function M.compact_content()
    return {
        "[  <CR>/L open  | H parent | yy copy | dd cut | P paste | x delete  ]",
    }
end

---@return string[]
local function content()
    return {
        "adev-files",
        "",
        "Navigation",
        "  <CR>/L/<Right>   enter directory / open file",
        "  H/<Left>/<BS>    parent directory",
        "  q               quit",
        "",
        "Clipboard",
        "  yy              copy (normal/visual)",
        "  dd              cut/move (normal/visual)",
        "  P               paste into current dir / dir under cursor",
        "  yc              clear clipboard",
        "",
        "Edits",
        "  Edit entries in-place, then :write to apply",
        "",
        "Delete",
        "  x               delete (normal/visual)",
        "",
        "Confirm",
        "  y/<CR>           confirm",
        "  n/q/<Esc>        cancel",
    }
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

    vim.keymap.set("n", "<esc>", "<cmd>bwipeout<CR>", { buffer = buf })
end

return M
