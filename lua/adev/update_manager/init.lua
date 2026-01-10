local utils = require "adev-common.utils"

local M = {}

---@param args string[] Git command arguments
---@param callback? fun(res: vim.SystemCompleted): nil Optional callback for async execution
---@return vim.SystemCompleted|nil Result if sync, nil if async
local function git_cmd(args, callback)
    local cmd = vim.list_extend({ Adev.git }, args)
    local process = vim.system(cmd, {
        cwd = utils.files.adev_path,
        text = true,
    }, function(res)
        if callback then callback(res) end
    end)
    if not callback then
        return process:wait()
    end
end

--- Fetches the latest tag from the remote for the given branch.
---@param branch? string Branch name (defaults to "main")
---@param callback fun(tag: string|nil): nil Called with the remote tag or nil on failure
local function get_remote_tag(branch, callback)
    git_cmd({ "fetch", "--tags" }, function(fetch_res)
        if not fetch_res or fetch_res.code ~= 0 then
            utils.err_notify "Failed to fetch tags"
            callback(nil)
            return
        end
        git_cmd({ "describe", "--tags", "--abbrev=0", "origin/" .. branch }, function(res)
            if not res or res.code ~= 0 or not res.stdout then
                utils.err_notify("Failed to get remote tag for origin/" .. branch)
                callback(nil)
                return
            end
            callback(vim.trim(res.stdout))
        end)
    end)
end

--- Gets the current local tag.
---@param callback fun(tag: string|nil): nil Called with the local tag or nil on failure
local function get_local_tag(callback)
    git_cmd({ "describe", "--tags", "--abbrev=0" }, function(res)
        if not res or res.code ~= 0 or not res.stdout then
            utils.err_notify "Failed to get local tag"
            callback(nil)
            return
        end
        callback(vim.trim(res.stdout))
    end)
end

--- Checks for updates and notifies the user.
--- Fetches latest tags, compares with local version, and shows notification.
function M.check_update()
    local branch = M.get_branch()
    get_remote_tag(branch, function(remote_tag)
        if not remote_tag then return end
        get_local_tag(function(local_tag)
            if not local_tag then return end
            if remote_tag == local_tag then
                utils.notify(string.format("adev.nvim: %s @ %s", local_tag, branch))
            else
                utils.notify(string.format("Update available: %s → %s @ %s", local_tag, remote_tag, branch), vim.log.levels.WARN)
            end
        end)
    end)
end

function M.update()
    local branch = M.get_branch()
    get_remote_tag(branch, function(remote_tag)
        if not remote_tag then return end
        get_local_tag(function(local_tag)
            if not local_tag then return end
            if remote_tag == local_tag then
                utils.notify(string.format("adev.nvim is up to date on %s", branch))
                return
            end
            git_cmd({ "checkout", remote_tag }, function(res)
                if res and res.code == 0 then
                    utils.notify(string.format("Updated to %s", remote_tag))
                    require("adev.onboarding"):onboarding()
                else
                    utils.err_notify(string.format("Failed to update to %s", remote_tag))
                end
            end)
        end)
    end)
end

---@return string|nil The current local tag (e.g., "v1.2.0") or nil if unavailable.
function M.get_version()
    local res = git_cmd({ "describe", "--tags", "--abbrev=0" })
    if res and res.stdout then
        return vim.trim(res.stdout)
    end
    return nil
end

---@return string|nil The current branch name or nil if unavailable.
function M.get_branch()
    local res = git_cmd({ "rev-parse", "--abbrev-ref", "HEAD" })
    if res and res.stdout then
        return vim.trim(res.stdout)
    end
    return nil
end

return M
