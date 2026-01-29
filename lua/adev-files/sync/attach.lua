local utils = require "adev-common.utils"

local apply = require "adev-files.sync.apply"
local index = require "adev-files.sync.index"
local plan = require "adev-files.sync.plan"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@param root string
function M.attach(buf, root)
    local st = state.init(buf, root)
    index.reindex(buf)

    local group = vim.api.nvim_create_augroup("adev_files_" .. buf, { clear = true })

    vim.api.nvim_create_autocmd("BufWriteCmd", {
        group = group,
        buffer = buf,
        callback = function(args)
            local b = args.buf
            local s = state.get(b)
            if not s or s.applying then
                return
            end

            -- Schedule UI work, otherwise UI providers can fail to focus
            -- when invoked during BufWriteCmd.
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(b) then
                    return
                end

                local s0 = state.get(b)
                if not s0 or s0.applying then
                    return
                end

                local ops0, err0 = plan.plan_ops(b)
                if not ops0 then
                    utils.err_notify(err0 or "failed to plan operations", "adev-files")
                    return
                end

                apply.apply_ops_with_confirm(b, ops0, { title = "adev-files" })
            end)
        end,
    })

    vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        buffer = buf,
        callback = function(args)
            state.clear(args.buf)
        end,
    })

    st.root = root
end

return M
