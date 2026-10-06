local utils = require "adev-common.utils"

local apply = require "adev-files.sync.apply"
local index = require "adev-files.sync.index"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local state = require "adev-files.state"

local parse = require "adev-files.parse"

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
            if not s or s.applying or s.confirming then
                return
            end

            -- Schedule UI work, otherwise UI providers can fail to focus
            -- when invoked during BufWriteCmd.
            vim.schedule(function()
                if not vim.api.nvim_buf_is_valid(b) then
                    return
                end

                local s0 = state.get(b)
                if not s0 or s0.applying or s0.confirming then
                    return
                end

                local ops0, err0 = plan.plan_ops(b)
                if not ops0 then
                    utils.err_notify(err0 or "failed to plan operations", "adev-files")
                    return
                end

                apply.apply_ops_with_confirm(b, ops0, {
                    title = "adev-files",
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

    local function schedule_update()
        local current = state.get(buf)
        if not current or current.applying or current.update_scheduled then
            return
        end
        current.update_scheduled = true
        vim.schedule(function()
            local latest = state.get(buf)
            if latest ~= current or not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            latest.update_scheduled = false
            if not latest.applying then
                render.add_virtual_text(buf, latest.root)
            end
        end)
    end

    local ids_by_row = {}
    for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
        local _, id = parse.strip_id(line)
        ids_by_row[i - 1] = id
    end
    vim.api.nvim_buf_attach(buf, false, {
        on_lines = function(_, b, _, first, last, new_last)
            local current = state.get(b)
            if not current then
                return true
            end
            local old_id = ids_by_row[first]
            local delta = new_last - last
            local next_ids, missing = {}, {}
            for row, id in pairs(ids_by_row) do
                if row < first then
                    next_ids[row] = id
                elseif row >= last then
                    next_ids[row + delta] = id
                end
            end
            for row, id in pairs(current.missing_ids or {}) do
                if row < first then
                    missing[row] = id
                elseif row >= last then
                    missing[row + delta] = id
                elseif row - first < new_last - first then
                    missing[row] = id
                end
            end
            for i, line in ipairs(vim.api.nvim_buf_get_lines(b, first, new_last, false)) do
                local _, id = parse.strip_id(line)
                local row = first + i - 1
                next_ids[row] = id
                if id then
                    missing[row] = nil
                end
            end
            if
                first >= 1
                and last - first == 1
                and new_last - first == 1
                and old_id
                and not next_ids[first]
            then
                missing[first] = old_id
            end
            ids_by_row = next_ids
            current.missing_ids = missing
            schedule_update()
        end,
    })
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = group,
        buffer = buf,
        callback = schedule_update,
    })

    -- Row 0 only anchors the virtual header. Keep the cursor on editable
    -- filesystem rows so the header cannot be modified accidentally.
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter", "BufWinEnter" }, {
        group = group,
        buffer = buf,
        callback = function(args)
            if vim.api.nvim_buf_line_count(args.buf) < 2 then
                return
            end
            local win = vim.fn.bufwinid(args.buf)
            if win == -1 then
                return
            end
            local cursor = vim.api.nvim_win_get_cursor(win)
            if cursor[1] == 1 then
                cursor = { 2, 0 }
            end
            local line = vim.api.nvim_buf_get_lines(args.buf, cursor[1] - 1, cursor[1], false)[1]
                or ""
            local _, _, prefix_length = parse.strip_id(line)
            cursor[2] = math.max(cursor[2], prefix_length)
            vim.wo[win].conceallevel = 3
            vim.wo[win].concealcursor = "nvic"
            vim.api.nvim_win_set_cursor(win, cursor)
        end,
    })

    st.root = root
end

return M
