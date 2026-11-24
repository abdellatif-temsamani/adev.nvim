local utils = require "adev-common.utils"

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

---@class AdevFilesGitMeta
---@field available boolean
---@field reason? string

--- Both repository discovery and status collection run asynchronously.
---@param root string
---@param callback fun(status: table<string, string>, files?: table<string, string>, meta?: AdevFilesGitMeta)
function M.fetch_status(root, callback)
    local Adev = rawget(_G, "Adev")
    local executable = (Adev and Adev.git) or "git"
    root = path.norm_real(root)

    local function deliver(status, files, meta)
        local handled, err = pcall(callback, status, files, meta)
        if not handled then
            utils.err_notify("git status callback failed: " .. tostring(err), "adev-files")
        end
    end
    local function fail(reason)
        deliver({}, {}, { available = false, reason = reason })
    end
    local function unavailable()
        fail "vim.system unavailable (Neovim 0.10+ required)"
    end

    if type(vim.system) ~= "function" then
        -- Avoid misreporting an API gap as a missing git executable.
        vim.schedule(unavailable)
        return
    end
    if vim.fn.executable(executable) ~= 1 then
        vim.schedule(function()
            fail("git executable not found: " .. tostring(executable))
        end)
        return
    end

    local function run(args, cwd, done)
        local ok = pcall(
            vim.system,
            args,
            { cwd = cwd, text = false, timeout = 10000 },
            function(result)
                vim.schedule(function()
                    local handled, err = pcall(done, result)
                    if not handled then
                        utils.err_notify("git status failed: " .. tostring(err), "adev-files")
                        fail("git status failed: " .. tostring(err))
                    end
                end)
            end
        )
        if not ok then
            vim.schedule(unavailable)
        end
    end

    run({ executable, "rev-parse", "--show-toplevel" }, root, function(result)
        if not result then
            fail("git command unavailable: " .. executable)
            return
        end
        if result.code == 124 then
            fail "git status timed out"
            return
        end
        if result.code ~= 0 then
            local stderr = (result.stderr or ""):gsub("[\r\n]+$", "")
            local reason = stderr ~= "" and stderr or "not a git repository"
            fail(reason)
            return
        end
        local git_root = (result.stdout or ""):gsub("[\r\n]+$", "")
        if git_root == "" then
            fail "not a git repository"
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
                if not status_result then
                    fail("git command unavailable: " .. executable)
                    return
                end
                if status_result.code == 124 then
                    fail "git status timed out"
                    return
                end
                if status_result.code ~= 0 then
                    local stderr = (status_result.stderr or ""):gsub("[\r\n]+$", "")
                    fail(stderr ~= "" and stderr or "git status failed")
                    return
                end
                local status, files = parse_porcelain(status_result.stdout or "", root, git_root)
                deliver(status, files, { available = true })
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
