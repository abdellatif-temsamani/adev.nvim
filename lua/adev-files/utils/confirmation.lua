local buffers = require "adev-common.utils.buffers"
local window = require "adev-common.ui.window"

local M = {}

---@class AdevFilesConfirmOpts
---@field title? string
---@field width? integer
---@field height? integer
---@field footer? string

---@param lines string[]
---@param opts? AdevFilesConfirmOpts
---@param cb fun(confirmed: boolean): nil
function M.open(lines, opts, cb)
    opts = opts or {}
    local content = {}
    for _, l in ipairs(lines or {}) do
        table.insert(content, l)
    end
    table.insert(content, "")
    table.insert(content, opts.footer or "y/<CR>: apply    n/q/<Esc>: cancel")

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

    window.floating_window({
        buf = buf,
        title = opts.title or "adev-files",
        width = opts.width or 80,
        height = opts.height or math.min(#content + 2, 20),
        wo = { wrap = true },
    })
end

return M
