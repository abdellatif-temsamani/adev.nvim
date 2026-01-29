local git = require "adev-common.git"
local utils = require "adev-common.utils"
local cache = require "adev.update.tag_cache"

local M = {}

function M.check_update()
    local now = vim.uv.now()
    local cached = cache.get_cached(now)
    if cached then
        utils.notify("adev.nvim: " .. cached)
        return
    end

    cache.fetch_latest(function(tag)
        if not tag then
            utils.notify("adev.nvim: Unable to check updates", vim.log.levels.WARN)
            return
        end
        utils.notify("adev.nvim: " .. tag)
    end, now)
end

function M.update()
    local now = vim.uv.now()
    local cached = cache.get_cached(now)

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

    if cached then
        proceed(cached)
        return
    end

    cache.fetch_latest(function(tag)
        proceed(tag)
    end, now)
end

return M
