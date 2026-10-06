local confirmation = require "adev-files.utils.confirmation"
local state = require "adev-files.state"
local sync = require "adev-files.sync"
local utils = require "adev-common.utils"

local M = {}

---@param buf integer
---@param cb fun(ok: boolean): nil
function M.confirm_discard_if_modified(buf, cb)
    local st = state.get(buf)
    if not st or st.applying or st.confirming then
        cb(false)
        return
    end
    if not require("adev-files.sync.view").has_changes(buf) then
        cb(true)
        return
    end
    st.confirming = true
    local modifiable = vim.bo[buf].modifiable
    vim.bo[buf].modifiable = false
    confirmation.open({ "Discard unsaved file changes?" }, {
        title = "adev-files",
        footer = "y/<CR>: discard    n/q/<Esc>: keep editing",
    }, function(confirmed)
        if not vim.api.nvim_buf_is_valid(buf) or state.get(buf) ~= st then
            cb(false)
            return
        end
        st.confirming = false
        vim.bo[buf].modifiable = modifiable
        if not confirmed then
            cb(false)
            return
        end
        local ok, err = sync.discard_reset(buf, { keep_clipboard = true })
        if not ok then
            utils.err_notify(err or "failed to discard changes", "adev-files")
        end
        cb(ok)
    end)
end

return M
