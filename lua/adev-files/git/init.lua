local path = require "adev-files.utils.fs.path"

local M = {}

local STATUS_PRIORITY = { U = 7, D = 6, M = 5, A = 4, R = 3, C = 2, ["?"] = 1 }
local UNMERGED = { DD = true, AU = true, UD = true, UA = true, DU = true, AA = true, UU = true }

local function worst_status(a, b)
    if not a then
        return b
    end
    if not b then
        return a
    end
    return (STATUS_PRIORITY[a] or 0) >= (STATUS_PRIORITY[b] or 0) and a or b
end

--- NUL-separated porcelain preserves spaces, quotes, newlines, and Unicode.
--- Rename/copy records contain the destination followed by a second source field.
local function parse_porcelain(output, root, git_root)
    local result, files = {}, {}
    local records = vim.split(output, "\0", { plain = true })
    local i = 1
    while i <= #records do
        local record = records[i]
        local x, y = record:sub(1, 1), record:sub(2, 2)
        local rel = record:sub(4)
        i = i + 1
        if x == "R" or y == "R" or x == "C" or y == "C" then
            i = i + 1
        end
        if #record >= 4 then
            local status
            if UNMERGED[x .. y] then
                status = "U"
            else
                x = x == "T" and "M" or x
                y = y == "T" and "M" or y
                status = worst_status(x ~= " " and x or nil, y ~= " " and y or nil)
            end
            local abs = path.join_abs(git_root, rel)
            local relative = path.relpath(root, abs)
            if status and relative ~= "." and relative ~= ".." and not relative:match "^%.%./" then
                relative = relative:gsub("/$", "")
                files[relative] = status
                result[relative] = worst_status(result[relative], status)
                local parent = vim.fs.dirname(relative)
                while parent and parent ~= "." and parent ~= "" do
                    result[parent] = worst_status(result[parent], status)
                    parent = vim.fs.dirname(parent)
                end
            end
        end
    end
    return result, files
end

--- Both repository discovery and status collection run asynchronously.
---@param root string
---@param callback fun(status: table<string, string>, files?: table<string, string>)
function M.fetch_status(root, callback)
    local executable = Adev and Adev.git or "git"
    root = path.norm_real(root)
    local function run(args, cwd, done)
        local ok = pcall(vim.system, args, { cwd = cwd, text = false }, function(result)
            vim.schedule(function()
                done(result)
            end)
        end)
        if not ok then
            vim.schedule(function()
                done(nil)
            end)
        end
    end

    run({ executable, "rev-parse", "--show-toplevel" }, root, function(result)
        if not result or result.code ~= 0 then
            callback({}, {})
            return
        end
        local git_root = (result.stdout or ""):gsub("[\r\n]+$", "")
        if git_root == "" then
            callback({}, {})
            return
        end
        run(
            {
                executable,
                "--no-optional-locks",
                "-c",
                "status.relativePaths=false",
                "status",
                "--porcelain=v1",
                "-z",
                "--untracked-files=all",
                "--renames",
            },
            git_root,
            function(status_result)
                if not status_result or status_result.code ~= 0 then
                    callback({}, {})
                    return
                end
                callback(parse_porcelain(status_result.stdout or "", root, git_root))
            end
        )
    end)
end

---@param git_status table<string, string>|nil
---@param rel_path string
---@return string|nil
function M.get_file_status(git_status, rel_path)
    return git_status and git_status[rel_path:gsub("/$", "")] or nil
end

return M
