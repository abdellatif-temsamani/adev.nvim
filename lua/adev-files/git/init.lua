local M = {}

local path = require "adev-files.utils.fs.path"

--- Status priority for directory aggregation (higher = more significant)
local STATUS_PRIORITY = {
    D = 6,
    M = 5,
    A = 4,
    R = 3,
    C = 2,
    ["?"] = 1,
}

---@param a string
---@param b string
---@return string
local function worst_status(a, b)
    if not a then
        return b
    end
    if not b then
        return a
    end
    local pa = STATUS_PRIORITY[a] or 0
    local pb = STATUS_PRIORITY[b] or 0
    return pa >= pb and a or b
end

--- Parse `git status --porcelain -u` output into a path -> status map
---@param output string
---@param root string  -- the directory being displayed
---@param git_root string -- the git repo root
---@return table<string, string>  -- rel_path (from root) -> status char
local function parse_porcelain(output, root, git_root)
    local result = {}
    for line in output:gmatch "[^\r\n]+" do
        local index_status = line:sub(1, 1)
        local worktree_status = line:sub(2, 2)
        local rel = line:sub(4)

        -- Handle rename: "R  old -> new"
        if index_status == "R" or worktree_status == "R" then
            local arrow = rel:find " %-> "
            if arrow then
                rel = rel:sub(arrow + 4)
            end
        end

        -- Compute the absolute path from git root
        local abs = path.abs(git_root .. "/" .. rel)

        -- Determine the effective status
        local status = index_status
        if status == " " then
            status = worktree_status
        end
        if status == "?" then
            status = "?"
        end

        -- Make path relative to the displayed root
        local rel_to_root = path.relpath(root, abs)

        -- Skip entries outside the displayed root
        if rel_to_root and not rel_to_root:match "^%.%." and rel_to_root ~= "." then
            -- Strip trailing slash normalization
            rel_to_root = rel_to_root:gsub("/$", "")

            result[rel_to_root] = status

            -- Propagate status up to parent directories
            local parts = vim.split(rel_to_root, "/", { plain = true, trimempty = true })
            local accumulated = ""
            for i = 1, #parts - 1 do
                accumulated = accumulated == "" and parts[i] or (accumulated .. "/" .. parts[i])
                result[accumulated] = worst_status(result[accumulated], status)
            end
        end
    end
    return result
end

--- Find the git root for a given directory
---@param root string
---@return string|nil
local function find_git_root(root)
    local git = Adev and Adev.git or "git"
    local res = vim.system({ git, "rev-parse", "--show-toplevel" }, {
        cwd = root,
        text = true,
    }):wait()
    if res and res.code == 0 then
        local gt = vim.trim(res.stdout or "")
        if gt ~= "" then
            return gt
        end
    end
    return nil
end

--- Fetch git status asynchronously for a root directory
---@param root string
---@param callback fun(status: table<string, string>)
function M.fetch_status(root, callback)
    local git_root = find_git_root(root)
    if not git_root then
        callback {}
        return
    end

    local git = Adev and Adev.git or "git"
    vim.system({ git, "status", "--porcelain", "-u", "-M" }, {
        cwd = git_root,
        text = true,
    }, function(res)
        vim.schedule(function()
            if not res or res.code ~= 0 then
                callback {}
                return
            end
            local status = parse_porcelain(res.stdout or "", root, git_root)
            callback(status)
        end)
    end)
end

--- Get git status character for a file/directory
---@param git_status table<string, string>|nil
---@param rel_path string
---@return string|nil
function M.get_file_status(git_status, rel_path)
    if not git_status then
        return nil
    end
    -- Strip trailing slash for lookup
    local key = rel_path:gsub("/$", "")
    return git_status[key]
end

return M
