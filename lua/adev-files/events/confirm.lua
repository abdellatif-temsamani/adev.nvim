local utils = require "adev-common.utils"

local confirmation = require "adev-files.utils.confirmation"
local sync = require "adev-files.sync"

local M = {}

---@param buf integer
---@param cb fun(ok: boolean): nil
function M.confirm_discard_if_modified(buf, cb)
    if not vim.bo[buf].modified then
        cb(true)
        return
    end

    vim.schedule(function()
        confirmation.open({ "Discard unsaved edits and navigate?" }, {
            title = "adev-files",
            width = 54,
            height = 6,
            footer = "y/<CR>: discard    n/q/<Esc>: cancel",
        }, function(confirmed)
            if confirmed then
                -- User explicitly chose to discard pending edits; reset immediately
                -- so we don't keep prompting for the same modified buffer.
                local ok, reset_err = sync.discard_reset(buf)
                if not ok and reset_err then
                    utils.err_notify(reset_err, "adev-files")
                end
            end
            cb(confirmed)
        end)
    end)
end

return M
