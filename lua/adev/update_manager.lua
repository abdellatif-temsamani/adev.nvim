local git = require "adev-common.git"
local utils = require "adev-common.utils"

local M = {}

local function get_remote_tag(branch, callback)
    git.git({ "fetch", "--tags" }, function(fetch_res)
        if not fetch_res or fetch_res.code ~= 0 then
            utils.err_notify "Failed to fetch tags"
            callback(nil)
            return
        end
        git.git({ "describe", "--tags", "--abbrev=0", "origin/" .. branch }, function(res)
            if not res or res.code ~= 0 or not res.stdout then
                utils.err_notify("Failed to get remote tag for origin/" .. branch)
                callback(nil)
                return
            end
            callback(vim.trim(res.stdout))
        end)
    end)
end

local function get_local_tag(callback)
    git.git({ "describe", "--tags", "--abbrev=0" }, function(res)
        if not res or res.code ~= 0 or not res.stdout then
            utils.err_notify "Failed to get local tag"
            callback(nil)
            return
        end
        callback(vim.trim(res.stdout))
    end)
end

function M.check_update()
    git.get_branch(function(branch)
        if not branch then
            return
        end
        get_remote_tag(branch, function(remote_tag)
            if not remote_tag then
                return
            end
            get_local_tag(function(local_tag)
                if not local_tag then
                    return
                end
                if remote_tag == local_tag then
                    utils.notify(string.format("adev.nvim: %s @ %s", local_tag, branch))
                else
                    utils.notify(
                        string.format(
                            "Update available: %s → %s @ %s",
                            local_tag,
                            remote_tag,
                            branch
                        ),
                        vim.log.levels.WARN
                    )
                end
            end)
        end)
    end)
end

function M.update()
    git.get_branch(function(branch)
        if not branch then
            return
        end
        get_remote_tag(branch, function(remote_tag)
            if not remote_tag then
                return
            end
            get_local_tag(function(local_tag)
                if not local_tag then
                    return
                end
                if remote_tag == local_tag then
                    utils.notify(string.format("adev.nvim is up to date on %s", branch))
                    return
                end
                git.git({ "checkout", remote_tag }, function(res)
                    if res and res.code == 0 then
                        utils.notify(string.format("Updated to %s", remote_tag))
                        require("adev.onboarding"):onboarding()
                    else
                        utils.err_notify(string.format("Failed to update to %s", remote_tag))
                    end
                end)
            end)
        end)
    end)
end

return M
