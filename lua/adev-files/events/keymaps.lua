local chmod = require "adev-files.events.chmod"
local clipboard = require "adev-files.events.clipboard"
local delete = require "adev-files.events.delete"
local help = require "adev-files.help"
local nav = require "adev-files.events.navigation"
local path = require "adev-files.utils.fs.path"
local revert = require "adev-files.events.revert"
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
            desc = "Disabled in file manager",
            silent = true,
        })
    end

    set_keymap("n", "<cr>", function()
        nav.open_or_enter(buf)
    end, { desc = "Open file or enter directory" })

    set_keymap("n", "u", "<nop>", { desc = "Disabled in file manager", silent = true })
    set_keymap("n", "<c-r>", "<nop>", { desc = "Disabled in file manager", silent = true })
    set_keymap("n", "K", "<nop>", { desc = "Disabled in file manager", silent = true })
    set_keymap("n", "J", "<nop>", { desc = "Disabled in file manager", silent = true })
    set_keymap("n", "dd", "<nop>", { desc = "Disabled in file manager", silent = true })
    set_keymap("n", "yy", "<nop>", { desc = "Disabled in file manager", silent = true })
    set_keymap("n", "D", "<nop>", { desc = "Disabled in file manager", silent = true })
    set_keymap("n", "<leader>bq", "<nop>", { desc = "Disabled in file manager", silent = true })
    set_keymap("n", "<leader>bs", function()
        vim.cmd "write"
    end, { desc = "Apply staged changes" })
    set_keymap("n", "L", function()
        nav.open_or_enter(buf)
    end, { desc = "Open file or enter directory" })
    set_keymap("n", "<right>", function()
        nav.open_or_enter(buf)
    end, { desc = "Open file or enter directory" })
    set_keymap("n", "H", function()
        nav.go_parent(buf)
    end, { desc = "Go to parent directory" })
    set_keymap("n", "<bs>", function()
        nav.go_parent(buf)
    end, { desc = "Go to parent directory" })
    set_keymap("n", "<left>", function()
        nav.go_parent(buf)
    end, { desc = "Go to parent directory" })

    set_keymap("n", "=", function()
        nav.go_root(buf)
    end, { desc = "Go to initial root" })
    set_keymap("n", "<leader>nq", function()
        nav.quit(buf)
    end, { desc = "Quit file manager" })
    set_keymap("n", "q", function()
        nav.quit(buf)
    end, { desc = "Quit file manager" })

    set_keymap("n", "<leader>nh", function()
        sync_view.toggle_hidden(buf)
    end, { desc = "Toggle hidden files" })

    set_keymap("n", "<leader>nf", function()
        sync_view.refresh(buf, { notify = true })
    end, { desc = "Refresh directory" })

    set_keymap("n", "<tab>", function()
        selection.toggle_mark(buf)
    end, { desc = "Toggle mark on current line" })
    set_keymap("n", "<leader>nm", function()
        selection.clear_marks(buf)
    end, { desc = "Clear all marks" })

    set_keymap({ "n", "x" }, "<leader>ny", function()
        clipboard.set_clipboard(buf, "copy")
    end, { desc = "Copy entries to clipboard" })
    set_keymap({ "n", "x" }, "<leader>nx", function()
        clipboard.set_clipboard(buf, "move")
    end, { desc = "Cut entries to clipboard" })
    set_keymap({ "n", "x" }, "<leader>nd", function()
        delete.delete_selected(buf)
    end, { desc = "Stage delete selected entries" })

    set_keymap("n", "<leader>nj", function()
        nav.next_modification(buf)
    end, { desc = "Jump to next changed entry" })
    set_keymap("n", "<leader>nk", function()
        nav.prev_modification(buf)
    end, { desc = "Jump to previous changed entry" })

    set_keymap("n", "<leader>nu", function()
        revert.revert_current_line(buf)
    end, { desc = "Revert current line" })

    set_keymap("n", "<leader>nz", function()
        chmod.chmod_entry(buf)
    end, { desc = "Change permissions" })

    set_keymap("n", "<leader>nc", function()
        sync_view.discard_reset(buf)
    end, { desc = "Reset all changes" })

    set_keymap("n", "?", function()
        help.open()
    end, { desc = "Open help" })

    set_keymap("n", "<leader>np", function()
        clipboard.paste(buf, "")
    end, { desc = "Paste clipboard into current directory" })

    set_keymap("n", "<leader>ns", function()
        local st = state.get(buf)
        local root = st and st.root or ""
        local rel = function(p)
            return p and p ~= "" and path.relpath(root, p) or ""
        end

        local lines = {}
        local ops, err = require("adev-files.sync").plan_ops(buf)
        if err then
            table.insert(lines, "")
            table.insert(lines, "  error: " .. err)
        elseif ops and #ops > 0 then
            if #lines > 0 then
                table.insert(lines, "")
            end
            table.insert(lines, "Changes pending:")
            for _, op in ipairs(ops) do
                if op.type == "create" then
                    table.insert(lines, "  created:    " .. rel(op.path))
                elseif op.type == "delete" then
                    table.insert(lines, "  deleted:    " .. rel(op.path))
                elseif op.type == "rename" then
                    table.insert(lines, "  renamed:    " .. rel(op.src) .. "  ->  " .. rel(op.dst))
                elseif op.type == "move" then
                    table.insert(lines, "  moved:      " .. rel(op.src) .. "  ->  " .. rel(op.dst))
                elseif op.type == "copy" then
                    table.insert(lines, "  copied:     " .. rel(op.src) .. "  ->  " .. rel(op.dst))
                end
            end
        end

        if #lines == 0 then
            vim.notify("(no changes)", vim.log.levels.INFO, { title = "adev-files" })
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
            title = "adev-files changes [q: close]",
            width = width,
            height = math.min(#lines + 2, 28),
            wo = { wrap = false },
            relative = "win",
            row = 0,
            col = vim.fn.winwidth(0),
        }

        local s_keys = utils.keymaps.buffer(sbuf)
        s_keys("n", "q", "<cmd>bwipeout<CR>", { desc = "Close pending changes" })
        s_keys("n", "<esc>", "<cmd>bwipeout<CR>", { desc = "Close pending changes" })
    end, { desc = "View pending changes" })
end

return M
