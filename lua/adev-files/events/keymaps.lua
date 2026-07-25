local clipboard = require "adev-files.events.clipboard"
local delete = require "adev-files.events.delete"
local help = require "adev-files.help"
local revert = require "adev-files.events.revert"
local nav = require "adev-files.events.navigation"
local path = require "adev-files.utils.fs.path"
local selection = require "adev-files.events.selection"
local state = require "adev-files.state"
local sync_view = require "adev-files.sync.view"
local utils = require "adev-common.utils"
local window = require "adev-common.ui.window"

local M = {}

---@param buf integer
function M.attach(buf)
    local set_keymap = utils.keymaps.buffer(buf)

    for _, lhs in ipairs { "<leader>no", "<leader>na", "<leader>nr", "<leader>nd" } do
        set_keymap("n", lhs, "<nop>", {
            desc = "disabled in adev-files",
            silent = true,
        })
    end

    set_keymap("n", "<cr>", function()
        nav.open_or_enter(buf)
    end)

    set_keymap("n", "K", "<nop>")
    set_keymap("n", "J", "<nop>")
    set_keymap("n", "dd", "<nop>")
    set_keymap("n", "yy", "<nop>")
    set_keymap("n", "D", "<nop>")
    set_keymap("n", "<leader>bq", "<nop>")
    set_keymap("n", "<leader>bs", function()
        vim.cmd "write"
    end)
    set_keymap("n", "L", function()
        nav.open_or_enter(buf)
    end)
    set_keymap("n", "<right>", function()
        nav.open_or_enter(buf)
    end)
    set_keymap("n", "H", function()
        nav.go_parent(buf)
    end)
    set_keymap("n", "<bs>", function()
        nav.go_parent(buf)
    end)
    set_keymap("n", "<left>", function()
        nav.go_parent(buf)
    end)

    set_keymap("n", "=", function()
        nav.go_root(buf)
    end)
    set_keymap("n", "<leader>nq", function()
        nav.quit(buf)
    end)

    set_keymap("n", "<leader>nh", function()
        sync_view.toggle_hidden(buf)
    end)

    set_keymap("n", "<tab>", function()
        selection.toggle_mark(buf)
    end)
    set_keymap("n", "<leader>nm", function()
        selection.clear_marks(buf)
    end)

    set_keymap({ "n", "x" }, "<leader>ny", function()
        clipboard.set_clipboard(buf, "copy")
    end)
    set_keymap({ "n", "x" }, "<leader>nx", function()
        clipboard.set_clipboard(buf, "move")
    end)
    set_keymap({ "n", "x" }, "<leader>nd", function()
        delete.delete_selected(buf)
    end)

    set_keymap("n", "<leader>nj", function()
        nav.next_modification(buf)
    end)
    set_keymap("n", "<leader>nk", function()
        nav.prev_modification(buf)
    end)

    set_keymap("n", "<leader>nu", function()
        revert.revert_current_line(buf)
    end)

    set_keymap("n", "<leader>nc", function()
        sync_view.discard_reset(buf)
    end)

    set_keymap("n", "?", function()
        help.open()
    end)

    set_keymap("n", "<leader>np", function()
        clipboard.paste(buf, "")
    end)

    set_keymap("n", "<leader>ns", function()
        local st = state.get(buf)
        local root = st and st.root or ""
        local rel = function(p)
            return p and p ~= "" and path.relpath(root, p) or ""
        end

        local lines = {}
        local pending = state.get_pending_ops(buf)
        if #pending > 0 then
            table.insert(lines, "Staged ops:")
            for _, op in ipairs(pending) do
                local opstr = op.type == "move" or op.type == "copy" and string.format("  %s %s -> %s", op.type, rel(op.src), rel(op.dst))
                    or op.type == "rename" and string.format("  rename %s -> %s", rel(op.src), rel(op.dst))
                    or op.type == "delete" and string.format("  delete %s", rel(op.path))
                    or op.type == "create" and string.format("  create %s", rel(op.path))
                    or string.format("  %s", vim.inspect(op))
                table.insert(lines, opstr)
            end
        end

        local ops, err = require("adev-files.sync").plan_ops(buf)
        if err then
            table.insert(lines, string.format("Error: %s", err))
        elseif ops and #ops > 0 then
            table.insert(lines, "")
            table.insert(lines, "Planned ops:")
            for _, op in ipairs(ops) do
                local opstr = op.type == "move" or op.type == "copy" and string.format("  %s %s -> %s", op.type, rel(op.src), rel(op.dst))
                    or op.type == "rename" and string.format("  rename %s -> %s", rel(op.src), rel(op.dst))
                    or op.type == "delete" and string.format("  delete %s", rel(op.path))
                    or op.type == "create" and string.format("  create %s", rel(op.path))
                    or string.format("  %s", vim.inspect(op))
                table.insert(lines, opstr)
            end
        end

        if #lines == 0 then
            vim.notify("(no pending changes)", vim.log.levels.INFO, { title = "adev-files" })
            return
        end

        local sbuf = vim.api.nvim_create_buf(false, true)
        vim.bo[sbuf].buftype = "nofile"
        vim.bo[sbuf].bufhidden = "wipe"
        vim.bo[sbuf].swapfile = false
        vim.bo[sbuf].modifiable = true
        vim.bo[sbuf].filetype = "adev_changes"
        vim.api.nvim_buf_set_lines(sbuf, 0, -1, false, lines)
        vim.bo[sbuf].modifiable = false

        local width = 72
        window.floating_window {
            buf = sbuf,
            title = "adev-files status [q: close]",
            width = width,
            height = math.min(#lines + 2, 28),
            wo = { wrap = false },
            relative = "win",
            row = 0,
            col = vim.fn.winwidth(0),
        }

        local s_keys = utils.keymaps.buffer(sbuf)
        s_keys("n", "q", "<cmd>bwipeout<CR>")
        s_keys("n", "<esc>", "<cmd>bwipeout<CR>")
    end)

end

return M
