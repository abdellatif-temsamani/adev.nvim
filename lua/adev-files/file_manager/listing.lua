local M = {}

---@param a string
---@param b string
local function sort_files(a, b)
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

--- Build file entry lines (without icons - icons are virtual text)
---@param root string
---@param opts? { show_hidden?: boolean }
---@return string[]
function M.build_lines(root, opts)
    local files, err = vim.fs.dir(root)
    if not files then
        return {}
    end

    local show_hidden = opts and opts.show_hidden or false

    -- Collect file entries
    local dirs = {}
    local files_list = {}
    for fname, ftype in files do
        if not show_hidden and fname:sub(1, 1) == "." then
            goto continue
        end
        local entry_name = fname
        if ftype == "directory" and entry_name:sub(-1) ~= "/" then
            entry_name = entry_name .. "/"
        end
        if ftype == "directory" then
            table.insert(dirs, entry_name)
        else
            table.insert(files_list, entry_name)
        end
        ::continue::
    end

    table.sort(dirs, sort_files)
    table.sort(files_list, sort_files)

    local entries = {}
    for _, d in ipairs(dirs) do
        table.insert(entries, d)
    end
    if #dirs > 0 and #files_list > 0 then
        table.insert(entries, "")
    end
    for _, f in ipairs(files_list) do
        table.insert(entries, f)
    end

    return entries
end

---@class AdevFilesSummary
---@field files integer
---@field directories integer
---@field pending integer
---@field show_hidden boolean
---@field git_counts table<string, integer>

---@param buf integer
---@param entries { row: integer, entry: AdevFilesEntry }[]
---@return AdevFilesSummary
function M.summarize(buf, entries)
    local st = require("adev-files.state").get(buf)
    local dir_count = 0
    local file_count = 0
    for _, item in ipairs(entries) do
        if item.entry.kind == "directory" then
            dir_count = dir_count + 1
        else
            file_count = file_count + 1
        end
    end
    local pending = st and st.pending_ops or {}
    local git_counts = {}
    local git_status = st and st.git_status
    if git_status then
        for _, s in pairs(git_status) do
            git_counts[s] = (git_counts[s] or 0) + 1
        end
    end
    return {
        files = file_count,
        directories = dir_count,
        pending = #pending,
        show_hidden = st and st.show_hidden or false,
        git_counts = git_counts,
    }
end

return M
