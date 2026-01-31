local help = require "adev-files.help"

local M = {}

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

    -- directories first (detected by trailing /)
    local a_is_dir = a:sub(-1) == "/"
    local b_is_dir = b:sub(-1) == "/"
    if a_is_dir ~= b_is_dir then
        return a_is_dir
    end

    -- same type -> compare names (strip trailing / for comparison)
    local a_name = a:gsub("/$", "")
    local b_name = b:gsub("/$", "")

    return a_name < b_name
end

--- Build header lines for virtual text display
--- Returns a list of {text, highlight_group} pairs for each line
---@param root string
---@return table[] header_lines Each item is {text, hl_group}
function M.build_header(root)
    local help_line = help.compact_content()[1]
    return {
        { help_line, "Comment" },
        { string.rep("=", #help_line), "Comment" },
        { "root: " .. root, "Directory" },
        { "", "Normal" },
    }
end

--- Build file entry lines (without icons - icons are virtual text)
---@param root string
---@return string[]
function M.build_lines(root)
    local files = vim.fs.dir(root)

    -- Collect file entries
    local entries = {}
    for name, type in files do
        if type == "directory" and name:sub(-1) ~= "/" then
            name = name .. "/"
        end
        table.insert(entries, name)
    end

    table.sort(entries, sort_files)
    return entries
end

return M
