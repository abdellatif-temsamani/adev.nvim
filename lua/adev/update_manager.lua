local git = require "adev-common.git"
local utils = require "adev-common.utils"

local M = {}

local cache = { tag = nil, timestamp = nil }
local CACHE_TTL = 300000

function M.check_update()
    local now = vim.uv.now()
    if cache.tag and (now - cache.timestamp) < CACHE_TTL then
        utils.notify("adev.nvim: " .. cache.tag)
        return
    end
    git.git({ "fetch", "--tags", "-q" }, function()
        git.get_available_versions(function(versions)
            if not versions or #versions == 0 then
                utils.notify("adev.nvim: Unable to check updates", vim.log.levels.WARN)
                return
            end
            local tag = versions[1]
            cache = { tag = tag, timestamp = now }
            utils.notify("adev.nvim: " .. tag)
        end)
    end)
end

function M.update()
    local now = vim.uv.now()
    local use_cache = cache.tag and (now - cache.timestamp) < CACHE_TTL
    local function proceed(tag)
        if not tag then
            utils.err_notify "Failed to get remote tag"
            return
        end
        local update_branch = "update/" .. tag
        git.get_branch(function(current_branch)
            if current_branch == update_branch then
                utils.notify "adev.nvim is up to date"
                return
            end
            git.git({ "checkout", "-B", update_branch, tag }, function(res)
                if res and res.code == 0 then
                    utils.notify("Updated to " .. tag)
                    vim.schedule(function()
                        require("adev.onboarding"):onboarding()
                    end)
                    git.git({ "branch", "--list", "update/*" }, function(branch_res)
                        if branch_res and branch_res.code == 0 and branch_res.stdout then
                            for old_branch in vim.gsplit(branch_res.stdout, "\n", { plain = true }) do
                                old_branch = vim.trim(old_branch)
                                if old_branch ~= "" and old_branch ~= update_branch then
                                    git.delete_branch(old_branch)
                                end
                            end
                        end
                    end)
                else
                    utils.err_notify("Failed to update to " .. tag)
                end
            end)
        end)
    end
    if use_cache then
        proceed(cache.tag)
    else
        git.git({ "fetch", "--tags", "-q" }, function()
            git.get_available_versions(function(versions)
                local tag = versions and #versions > 0 and versions[1] or nil
                if tag then
                    cache = { tag = tag, timestamp = now }
                end
                proceed(tag)
            end)
        end)
    end
end

return M
