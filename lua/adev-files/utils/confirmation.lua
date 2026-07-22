local buffers = require "adev-common.utils.buffers"
local keymaps = require "adev-common.utils.keymaps"
local window = require "adev-common.ui.window"

local M = {}

---@class AdevFilesConfirmOpts
---@field title? string
---@field width? integer
---@field height? integer
---@field footer? string

local CONFIRM_NS = vim.api.nvim_create_namespace "adev_files_confirm"

---@param lines string[]
---@param opts? AdevFilesConfirmOpts
---@param cb fun(confirmed: boolean): nil
function M.open(lines, opts, cb)
    opts = opts or {}
    local content = {}
    for _, l in ipairs(lines or {}) do
        table.insert(content, l)
    end
    -- Footer is now virtual text, not real buffer content

    local buf = buffers.create(content, {
        scratch = true,
        listed = false,
        bo = {
            modifiable = false,
            swapfile = false,
            bufhidden = "wipe",
            filetype = "adev_files_confirm",
        },
    })

    -- Add footer as virtual text below the content
    local footer = opts.footer or "y/<CR>: apply    n/q/<Esc>: cancel"
    local last_line = math.max(0, #content - 1)
    vim.api.nvim_buf_set_extmark(buf, CONFIRM_NS, last_line, 0, {
        virt_lines = {
            { { "", "Normal" } },
            { { footer, "Comment" } },
        },
        virt_lines_above = false,
    })

    window.floating_window {
        buf = buf,
        title = opts.title or "adev-files",
        width = opts.width or 80,
        height = opts.height or math.min(#content + 2, 20),
        wo = { wrap = true },
    }

    local finished = false
    local function cleanup()
        -- Deleting a displayed buffer can leave a floating window alive with
        -- an empty replacement buffer. Close every window first, then wipe the
        -- confirmation buffer if it still exists.
        for _, win_id in ipairs(vim.fn.win_findbuf(buf)) do
            if vim.api.nvim_win_is_valid(win_id) then
                pcall(vim.api.nvim_win_close, win_id, true)
            end
        end
        if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end

    local function finish(confirmed)
        if finished then
            return
        end
        finished = true
        cleanup()

        if cb then
            local ok, err = xpcall(cb, debug.traceback, confirmed)
            if not ok then
                vim.schedule(function()
                    vim.notify("adev-files: " .. tostring(err), vim.log.levels.ERROR)
                end)
            end
        end
    end

    -- Install these after floating_window(), whose generic q mapping would
    -- otherwise override confirmation cancellation.
    local set_keymap = keymaps.buffer(buf)
    set_keymap("n", "y", function()
        finish(true)
    end)
    set_keymap("n", "<cr>", function()
        finish(true)
    end)
    set_keymap("n", "n", function()
        finish(false)
    end)
    set_keymap("n", "q", function()
        finish(false)
    end)
    set_keymap("n", "<esc>", function()
        finish(false)
    end)
end

return M
