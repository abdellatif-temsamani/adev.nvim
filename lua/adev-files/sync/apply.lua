local utils = require "adev-common.utils"

local clipboard = require "adev-files.clipboard"
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
---@return string
local function summarize_ops(ops)
    local counts = {}
    for _, op in ipairs(ops) do
        counts[op.type] = (counts[op.type] or 0) + 1
    end
    local parts = {}
    local order = { "create", "rename", "delete", "copy", "move" }
    for _, t in ipairs(order) do
        local c = counts[t]
        if c and c > 0 then
            table.insert(parts, string.format("%d %s", c, t))
        end
    end
    if #parts == 0 then
        return string.format("Applied %d changes", #ops)
    end
    return string.format("Applied %d changes (%s)", #ops, table.concat(parts, ", "))
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
    if not st or st.applying or st.confirming then
        return
    end

    local fs_n = count_fs_ops(ops)
    if fs_n == 0 then
        if not view.refresh(buf) then
            vim.bo[buf].modifiable = false
            vim.bo[buf].modified = false
            utils.notify(
                "No changes saved. Refresh the directory when it becomes available",
                vim.log.levels.WARN,
                "adev-files"
            )
        end
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

    local root = st.root
    local changedtick = vim.api.nvim_buf_get_changedtick(buf)
    local modifiable = vim.bo[buf].modifiable
    st.confirming = true
    vim.bo[buf].modifiable = false
    confirmation.open(lines, { title = opts.title or "adev-files" }, function(confirmed)
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        -- Restore editability even when another attachment replaced the state.
        vim.bo[buf].modifiable = modifiable
        if state.get(buf) ~= st then
            return
        end
        st.confirming = false
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
        if st2.root ~= root or vim.api.nvim_buf_get_changedtick(buf) ~= changedtick then
            utils.err_notify("Changes were edited while confirming; write again", "adev-files")
            return
        end

        st2.applying = true
        local ok, applied, apply_message, outcome = pcall(apply_ops, ops)
        st2.applying = false

        if not ok then
            utils.err_notify(tostring(applied or "failed to apply changes"), "adev-files")
            return
        end
        if not applied then
            utils.err_notify(apply_message or "failed to apply changes", "adev-files")
            return
        end
        -- Cleanup failed after commit: report the error instead of claiming a
        -- clean success, but still treat the operations as applied below.
        if outcome == "cleanup_failed" then
            utils.err_notify(apply_message or "transaction cleanup failed", "adev-files")
        else
            if apply_message then
                utils.notify(apply_message, vim.log.levels.WARN, "adev-files")
            end
            utils.notify(summarize_ops(ops), vim.log.levels.INFO, "adev-files")
        end

        -- Refresh after clearing `applying`, otherwise refresh is a no-op.
        clipboard.apply_path_changes(ops)
        state.clear_pending_ops(buf)
        st2.needs_refresh = true
        st2.refresh_modifiable = modifiable
        if not view.refresh(buf, { force = true }) then
            vim.bo[buf].modifiable = false
            vim.bo[buf].modified = false
            utils.notify(
                "Changes saved. Refresh the directory when it becomes available",
                vim.log.levels.WARN,
                "adev-files"
            )
        end

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
                    local entry = require("adev-files.parse").parse_line(line)
                    if entry and entry.fs_name == target_fname then
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
