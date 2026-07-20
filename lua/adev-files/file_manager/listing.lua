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

--- Build header lines for display
---@param root string
---@return string[]
function M.build_header(root)
    local result = {}
    table.insert(result, string.rep("=", 72))
    table.insert(result, "root: " .. root)
    table.insert(result, "")
    return result
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

---@param buf integer
---@param entries { row: integer, entry: AdevFilesEntry }[]
---@return string
function M.build_footer_line(buf, entries)
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
    local parts = { string.format("  Files: %d  Dirs: %d", file_count, dir_count) }
    local pending = st and st.pending_ops or {}
    if #pending > 0 then
        table.insert(parts, string.format("  Pending: %d", #pending))
    end
    if st and st.show_hidden then
        table.insert(parts, "  .hidden on")
    end
    local git_status = st and st.git_status
    if git_status then
        local counts = {}
        for _, s in pairs(git_status) do
            counts[s] = (counts[s] or 0) + 1
        end
        local order = { "M", "A", "D", "R", "C", "?" }
        local git_parts = {}
        for _, code in ipairs(order) do
            if counts[code] and counts[code] > 0 then
                table.insert(git_parts, code .. ":" .. counts[code])
            end
        end
        if #git_parts > 0 then
            table.insert(parts, "  Git: " .. table.concat(git_parts, " "))
        end
    end
    return table.concat(parts, "  |")
end

return M
