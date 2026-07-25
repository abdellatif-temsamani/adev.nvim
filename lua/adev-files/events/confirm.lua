local utils = require "adev-common.utils"
local sync = require "adev-files.sync"

local M = {}

---@param buf integer
---@param cb fun(ok: boolean): nil
function M.confirm_discard_if_modified(buf, cb)
    if vim.bo[buf].modified then
        local ok, reset_err = sync.discard_reset(buf)
        if not ok and reset_err then
            utils.err_notify(reset_err, "adev-files")
        end
    end
    cb(true)
end

return M
