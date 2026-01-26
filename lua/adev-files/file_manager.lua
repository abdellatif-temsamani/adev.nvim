local ui = require "adev-common.ui"
local utils = require "adev-common.utils"

local M = { buf = -1 }

--- create a popup window to list files
---@param buf integer buffer id
---@param height integer height of window
function M.create_win(buf, height)
    ui.window.floating_window {
        title = "Adev Files [q: quit]",
        buf = buf,
        width = 64,
        height = height,
        border = "single",
        wo = {
            cursorline = true,
            cursorlineopt = "line",
        },
    }
end

---@param a string
---@param b string
function M.sort_files(a, b)
    -- root: first
    if a:sub(1, 5) == "root:" and b:sub(1, 5) ~= "root:" then
        return true
    elseif b:sub(1, 5) == "root:" and a:sub(1, 5) ~= "root:" then
        return false
    end

    -- empty string next
    if a == "" and b ~= "" then
        return true
    elseif b == "" and a ~= "" then
        return false
    end

    -- directories first
    local a_is_dir = a:sub(1, 10) == "directory:"
    local b_is_dir = b:sub(1, 10) == "directory:"
    if a_is_dir ~= b_is_dir then
        return a_is_dir
    end

    -- same type → compare names (trim prefix)
    local a_name = a:gsub("^(directory|file):%s*", "")
    local b_name = b:gsub("^(directory|file):%s*", "")

    return a_name < b_name
end

function M.open()
    local pwd = utils.files.get_dirname()
    local files = vim.fs.dir(pwd)

    local current_files = { "root: " .. pwd }
    for name, type in files do
        table.insert(current_files, string.format("%s: %s", type, name))
    end
    table.sort(current_files, M.sort_files)

    local buf = utils.buffers.create(current_files, {
        scratch = true,
        listed = false,
        bo = {
            filetype = "adev_files",
            modifiable = false,
            bufhidden = "wipe",
        },
    })

    M.create_win(buf, #current_files)
end

return M
