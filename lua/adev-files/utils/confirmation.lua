local buffers = require "adev-common.utils.buffers"
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

    local finished = false
    local finish = function(ok)
        if finished then
            return
        end
        finished = true
        if cb then
            cb(ok)
        end
        if vim.api.nvim_buf_is_valid(buf) then
            pcall(vim.api.nvim_buf_delete, buf, { force = true })
        end
    end

    vim.keymap.set("n", "y", function()
        finish(true)
    end, { buffer = buf })
    vim.keymap.set("n", "<cr>", function()
        finish(true)
    end, { buffer = buf })
    vim.keymap.set("n", "n", function()
        finish(false)
    end, { buffer = buf })
    vim.keymap.set("n", "q", function()
        finish(false)
    end, { buffer = buf })
    vim.keymap.set("n", "<esc>", function()
        finish(false)
    end, { buffer = buf })

    window.floating_window {
        buf = buf,
        title = opts.title or "adev-files",
        width = opts.width or 80,
        height = opts.height or math.min(#content + 2, 20),
        wo = { wrap = true },
    }
end

return M
