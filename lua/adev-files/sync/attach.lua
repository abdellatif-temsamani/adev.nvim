local utils = require "adev-common.utils"

local apply = require "adev-files.sync.apply"
local clipboard = require "adev-files.clipboard"
local index = require "adev-files.sync.index"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local state = require "adev-files.state"

local view = require "adev-files.core.view"

local M = {}

---@param buf integer
---@param root string
function M.attach(buf, root)
    local st = state.init(buf, root)
    index.index_original(buf)
    index.reindex(buf)
    render.add_virtual_text(buf, root)

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

                local has_move = false
                for _, op in ipairs(ops0) do
                    if op.type == "move" then
                        has_move = true
                        break
                    end
                end

                apply.apply_ops_with_confirm(b, ops0, {
                    title = "adev-files",
                    on_success = function()
                        state.clear_pending_ops(b)
                        if has_move then
                            local clip = clipboard.get()
                            if clip and clip.mode == "move" then
                                clipboard.clear()
                            end
                        end
                    end,
                })
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

    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = group,
        buffer = buf,
        callback = function(args)
            local b = args.buf
            local s = state.get(b)
            if not s or s.applying then
                return
            end

            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(b) then
                    return
                end
                local s0 = state.get(b)
                if not s0 or s0.applying then
                    return
                end
                index.reindex(b)
                render.add_virtual_text(b, s0.root)

                if not vim.bo[b].modified then
                    return
                end

                local entries, err = view.parse_buffer(b)
                if err or not entries then
                    return
                end
                local original = state.get_original_lines(b)
                local n = 0
                for _, _ in pairs(original) do
                    n = n + 1
                end
                if #entries ~= n then
                    return
                end
                local entry_names = {}
                local orig_names = {}
                for i, item in ipairs(entries) do
                    entry_names[i] = item.entry.fs_name
                end
                local idx = 0
                for _, data in pairs(original) do
                    idx = idx + 1
                    orig_names[idx] = data.entry.fs_name
                end
                table.sort(entry_names)
                table.sort(orig_names)
                for i, name in ipairs(entry_names) do
                    if name ~= orig_names[i] then
                        return
                    end
                end
                vim.bo[b].modified = false
            end)
        end,
    })

    -- Row 0 only anchors the virtual header. Keep the cursor on editable
    -- filesystem rows so the header cannot be modified accidentally.
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
        buffer = buf,
        callback = function(args)
            if vim.api.nvim_buf_line_count(args.buf) < 2 then
                return
            end
            local win = vim.fn.bufwinid(args.buf)
            if win ~= -1 and vim.api.nvim_win_get_cursor(win)[1] == 1 then
                vim.api.nvim_win_set_cursor(win, { 2, 0 })
            end
        end,
    })

    st.root = root
end

return M
