local ui = require "adev-common.ui"
local utils = require "adev-common.utils"

--- create a popup window to list files
---@param buf integer buffer id
---@param height integer height of window
local function create_win(buf, height)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "adev_files"

    vim.keymap.set({ "n", "v" }, "q", "<cmd>bwipeout<CR>", { buffer = buf })
    ui.window:new_floating(buf, {
        height = height,
    })
end

---@param a string
---@param b string
local function sort_files(a, b)
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

return function()
    local pwd = utils.files.get_dirname()
    local files = vim.fs.dir(pwd)

    local current_files = { "root: " .. pwd, "" }
    for name, type in files do
        table.insert(current_files, string.format("%s: %s", type, name))
    end
    table.sort(current_files, sort_files)
    local buf = ui.window.create_buf(current_files, true, true)

    create_win(buf, #current_files)
end
