local path = require "adev-files.utils.fs.path"
local render = require "adev-files.file_manager.render"
local selection = require "adev-files.events.selection"
local state = require "adev-files.state"
local uv = vim.uv or vim.loop

local M = {}

local BITS = { 256, 128, 64, 32, 16, 8, 4, 2, 1 }
local GUIDE_NS = vim.api.nvim_create_namespace "adev_files_chmod_guide"

local function perm_from_str(str)
    str = str:gsub("%s+", "")
    -- Four octal digits preserve setuid/setgid/sticky bits (0o7777).
    if str:match "^[0-7]+$" and #str <= 4 then
        return tonumber(str, 8)
    end
    if not str:match "^[r%-][w%-][xsXS%-][r%-][w%-][xsXS%-][r%-][w%-][xtXT%-]$" then
        return nil
    end
    local num = 0
    for i = 1, 9 do
        local ch = str:sub(i, i)
        if ch == "r" or ch == "w" or ch == "x" then
            num = num + BITS[i]
        elseif ch == "s" or ch == "S" then
            if i == 3 then
                num = num + 2048
            elseif i == 6 then
                num = num + 1024
            end
            if ch == "s" then
                num = num + BITS[i]
            end
        elseif ch == "t" or ch == "T" then
            num = num + 512
            if ch == "t" then
                num = num + BITS[i]
            end
        end
    end
    return num
end

local function format_mode(mode)
    return render.format_mode(mode)
end

local function highlight_perm_chars(buf, lines)
    for row, line in ipairs(lines) do
        if row == 3 then
            for col = 1, #line do
                local ch = line:sub(col, col)
                local hl = ch == "r" and "adevFilesPermRead"
                    or ch == "w" and "adevFilesPermWrite"
                    or ch == "x" and "adevFilesPermExec"
                    or ch == "-" and "adevFilesPermDash"
                if hl then
                    vim.api.nvim_buf_set_extmark(buf, GUIDE_NS, row - 1, col - 1, {
                        hl_group = hl,
                        end_col = col,
                    })
                end
            end
        elseif line:match "^  [rwx%-] =" then
            local ch = line:sub(3, 3)
            local hl = ch == "r" and "adevFilesPermRead"
                or ch == "w" and "adevFilesPermWrite"
                or ch == "x" and "adevFilesPermExec"
                or "adevFilesPermDash"
            vim.api.nvim_buf_set_extmark(buf, GUIDE_NS, row - 1, 2, {
                hl_group = hl,
                end_col = 3,
            })
        end
    end
end

local function show_guide(perm_str)
    local owner = perm_str:sub(1, 3)
    local group = perm_str:sub(4, 6)
    local other = perm_str:sub(7, 9)

    local lines = {
        "",
        string.format("  %-5s  %-5s  %-5s", "owner", "group", "other"),
        string.format("  %-5s  %-5s  %-5s", owner, group, other),
        "",
        "  r = read",
        "    file: read contents   dir: list entries",
        "  w = write",
        "    file: modify contents dir: create/delete",
        "  x = execute",
        "    file: run as program  dir: enter directory",
        "  - = no permission",
        "",
        "  also accepts octal: 755, 644, etc.",
    }

    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "adev_files_confirm"

    highlight_perm_chars(buf, lines)

    local ui = vim.api.nvim_list_uis()[1] or { width = 80, height = 24 }
    local width = math.min(58, math.max(20, ui.width - 4))
    local height = math.min(#lines, math.max(3, ui.height - 6))
    local row = math.max(0, math.min(5, ui.height - height - 2))
    local col = math.max(0, math.floor((ui.width - width) / 2))

    vim.api.nvim_open_win(buf, false, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "single",
        title = " Permissions guide ",
    })

    vim.keymap.set("n", "q", function()
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_delete(buf, { force = true })
        end
    end, { buffer = buf })

    return buf
end

function M.chmod_entry(buf)
    local st = state.get(buf)
    if not st or st.applying or st.confirming or st.needs_refresh then
        return
    end

    local items, _ = selection.collect_entries_with_rows(buf)
    if #items == 0 then
        return
    end

    local target = items[1]
    local stat = uv.fs_stat(target.src)
    if not stat then
        vim.notify("Cannot stat: " .. target.src, vim.log.levels.ERROR, { title = "adev-files" })
        return
    end

    local current = format_mode(stat.mode)
    local label = #items == 1 and path.relpath(st.root, target.src)
        or (tostring(#items) .. " items")

    local guide_buf = show_guide(current)
    local guide_windows = vim.fn.win_findbuf(guide_buf)

    vim.ui.input({
        prompt = "Permissions for " .. label .. " (" .. current .. "): ",
        default = current,
    }, function(input)
        for _, win in ipairs(guide_windows) do
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end
        -- The guide buffer is bufhidden=wipe: closing its windows is enough.
        if not input or input == "" then
            return
        end
        if
            not vim.api.nvim_buf_is_valid(buf)
            or state.get(buf) ~= st
            or st.applying
            or st.confirming
            or st.needs_refresh
        then
            return
        end
        local mode = perm_from_str(input)
        if not mode or mode < 0 or mode > 4095 then
            vim.notify("Invalid mode: " .. input, vim.log.levels.ERROR, { title = "adev-files" })
            return
        end
        local ok_count = 0
        local failures = {}
        for _, item in ipairs(items) do
            local ok, err = uv.fs_chmod(item.src, mode)
            if ok then
                ok_count = ok_count + 1
            else
                local name = path.relpath(st.root, item.src)
                table.insert(failures, name)
                vim.notify(
                    "Chmod failed: " .. name .. " - " .. tostring(err),
                    vim.log.levels.ERROR,
                    { title = "adev-files" }
                )
            end
        end
        if ok_count > 0 or #failures > 0 then
            local msg = string.format(
                "Chmod %s: %d applied, %d failed",
                format_mode(mode),
                ok_count,
                #failures
            )
            if #failures > 0 then
                msg = msg .. ": " .. table.concat(failures, ", ")
            end
            vim.notify(
                msg,
                #failures > 0 and vim.log.levels.WARN or vim.log.levels.INFO,
                { title = "adev-files" }
            )
            if ok_count > 0 then
                render.add_virtual_text(buf, st.root)
            end
        end
    end)
end

return M
