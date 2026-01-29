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

    local ops, err = sync.plan_ops(buf)
    if ops and #ops == 0 then
        -- Some edits can flip the modified flag but don't translate into
        -- filesystem operations. Treat those as safe to discard and reset view.
        sync.refresh(buf)
        cb(true)
        return
    end

    vim.schedule(function()
        if err then
            utils.notify(
                "Pending edits could not be parsed; discarding will reset the view",
                vim.log.levels.WARN,
                "adev-files"
            )
        end
        confirmation.open({ "Discard unsaved edits and navigate?" }, {
            title = "adev-files",
            width = 54,
            height = 6,
            footer = "y/<CR>: discard    n/q/<Esc>: cancel",
        }, function(confirmed)
            if confirmed then
                -- User explicitly chose to discard pending edits; reset immediately
                -- so we don't keep prompting for the same modified buffer.
                sync.refresh(buf)
            end
            cb(confirmed)
        end)
    end)
end

return M
