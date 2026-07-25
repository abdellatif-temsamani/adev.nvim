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
    if str:match "^%d+$" then
        return tonumber(str, 8)
    end
    local num = 0
    for i = 1, 9 do
        local ch = str:sub(i, i)
        if ch == "r" or ch == "w" or ch == "x" then
            num = num + BITS[i]
        end
    end
    return num
end

local function format_mode(mode)
    if not mode then
        return nil
    end
    local perm = mode % 512
    local result = {}
    for i = 1, 9 do
        if perm >= BITS[i] then
            perm = perm - BITS[i]
            result[i] = ({ "r", "w", "x", "r", "w", "x", "r", "w", "x" })[i]
        else
            result[i] = "-"
        end
    end
    return table.concat(result)
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

    local width = 58
    local height = #lines
    local ui = vim.api.nvim_list_uis()[1]
    local row = 5
    local col = ui and math.floor((ui.width - width) / 2) or 10

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
    if not st or st.applying then
        return
    end

    local items, _ = selection.collect_entries_with_rows(buf)
    if #items == 0 then
        return
    end

    local target = items[1]
    local stat = uv.fs_stat(target.src)
    if not stat then
        vim.notify("Cannot stat: " .. target.src, vim.log.levels.ERROR, "adev-files")
        return
    end

    local current = format_mode(stat.mode)
    local label = #items == 1 and path.relpath(st.root, target.src)
        or (tostring(#items) .. " items")

    local guide_buf = show_guide(current)

    vim.ui.input({
        prompt = "Permissions for " .. label .. " (" .. current .. "): ",
        default = current,
    }, function(input)
        if guide_buf and vim.api.nvim_buf_is_valid(guide_buf) then
            vim.api.nvim_buf_delete(guide_buf, { force = true })
        end
        if not input or input == "" then
            return
        end
        local mode = perm_from_str(input)
        if not mode or mode < 0 or mode > 511 then
            vim.notify("Invalid mode: " .. input, vim.log.levels.ERROR, "adev-files")
            return
        end
        local ok_count = 0
        for _, item in ipairs(items) do
            local ok, err = uv.fs_chmod(item.src, mode)
            if ok then
                ok_count = ok_count + 1
            else
                vim.notify(
                    "Chmod failed: " .. path.relpath(st.root, item.src) .. " - " .. tostring(err),
                    vim.log.levels.ERROR,
                    "adev-files"
                )
            end
        end
        if ok_count > 0 then
            vim.notify(
                "Chmod: " .. format_mode(mode) .. " (" .. ok_count .. " items)",
                vim.log.levels.INFO,
                "adev-files"
            )
            render.add_virtual_text(buf, st.root)
        end
    end)
end

return M
