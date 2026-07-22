local utils = require "adev-common.utils"

local confirmation = require "adev-files.utils.confirmation"
local executor = require "adev-files.core.executor"
local fmt = require "adev-files.sync.format"
local state = require "adev-files.state"
local view = require "adev-files.sync.view"

local M = {}

---@param ops AdevFilesOp[]
---@return integer
local function count_fs_ops(ops)
    local n = 0
    for _, _ in ipairs(ops) do
        n = n + 1
    end
    return n
end

---@param ops AdevFilesOp[]
---@return boolean, string?
local function apply_ops(ops)
    return executor.apply_ops(ops)
end

---@class AdevFilesApplyOpts
---@field title? string
---@field preface? string[]
---@field on_success? fun(): nil
---@field on_cancel? fun(): nil

---@param buf integer
---@param ops AdevFilesOp[]
---@param opts? AdevFilesApplyOpts
function M.apply_ops_with_confirm(buf, ops, opts)
    opts = opts or {}
    local st = state.get(buf)
    if not st or st.applying then
        return
    end

    local fs_n = count_fs_ops(ops)
    if fs_n == 0 then
        view.refresh(buf)
        return
    end

    local lines = fmt.format_ops(st, ops)
    if opts.preface and #opts.preface > 0 then
        local merged = {}
        for _, l in ipairs(opts.preface) do
            table.insert(merged, l)
        end
        table.insert(merged, "")
        for _, l in ipairs(lines) do
            table.insert(merged, l)
        end
        lines = merged
    end

    confirmation.open(lines, { title = opts.title or "adev-files" }, function(confirmed)
        if not confirmed then
            if opts.on_cancel then
                opts.on_cancel()
            end
            utils.notify("Cancelled", vim.log.levels.INFO, "adev-files")
            return
        end

        local st2 = state.get(buf)
        if not st2 or st2.applying then
            return
        end

        st2.applying = true
        local ok, apply_ok_or_err, apply_err_msg = pcall(apply_ops, ops)
        st2.applying = false

        if not ok then
            utils.err_notify(tostring(apply_ok_or_err or "failed to apply changes"), "adev-files")
            return
        end
        if not apply_ok_or_err then
            utils.err_notify(apply_err_msg or "failed to apply changes", "adev-files")
            return
        end
        if apply_err_msg then
            utils.notify(apply_err_msg, vim.log.levels.WARN, "adev-files")
        end

        -- Refresh after clearing `applying`, otherwise refresh is a no-op.
        view.refresh(buf)

        -- Jump cursor to the first newly created entry
        local create_ops = {}
        for _, op in ipairs(ops) do
            if op.type == "create" then
                table.insert(create_ops, op)
            end
        end
        if #create_ops > 0 then
            local target_fname = vim.fn.fnamemodify(create_ops[1].path, ":t")
            if target_fname ~= "" then
                local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                local target_row = nil
                for i, line in ipairs(buf_lines) do
                    local stripped = line:gsub("/$", "")
                    if stripped == target_fname then
                        target_row = i
                        break
                    end
                end
                if target_row then
                    -- Find the window displaying this buffer
                    local win_id = nil
                    for _, w in ipairs(vim.api.nvim_list_wins()) do
                        if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_buf(w) == buf then
                            win_id = w
                            break
                        end
                    end
                    if win_id then
                        vim.api.nvim_set_current_win(win_id)
                        pcall(vim.api.nvim_win_set_cursor, win_id, { target_row, 0 })
                    end
                end
            end
        end

        if opts.on_success then
            opts.on_success()
        end
    end)
end

return M
