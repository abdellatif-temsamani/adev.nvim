local git = require "adev-common.git"
local utils = require "adev-common.utils"

local M = {}

local cache = { remote_tag = nil, timestamp = nil }
local CACHE_TTL = 300000

local function version_greater(v1, v2)
    local n1, n2, n3 = v1:match("v(%d+)%.(%d+)%.(%d+)")
    local m1, m2, m3 = v2:match("v(%d+)%.(%d+)%.(%d+)")
    n1, n2, n3 = tonumber(n1) or 0, tonumber(n2) or 0, tonumber(n3) or 0
    m1, m2, m3 = tonumber(m1) or 0, tonumber(m2) or 0, tonumber(m3) or 0
    if n1 ~= m1 then return n1 > m1 end
    if n2 ~= m2 then return n2 > m2 end
    return n3 > m3
end

local function fetch_and_get_tag(callback)
    local timeout_ms = 5000
    local done = false
    local function finish(tag)
        if not done then
            done = true
            callback(tag)
        end
    end
    vim.fn.jobstart({ "git", "fetch", "--tags", "-q" }, {
        timeout = timeout_ms,
        on_exit = function(_, code)
            if code ~= 0 then
                finish(nil)
                return
            end
            git.git({ "describe", "--tags", "--abbrev=0", "origin/main" }, function(res)
                if not res or res.code ~= 0 or not res.stdout then
                    finish(nil)
                    return
                end
                finish(vim.trim(res.stdout))
            end)
        end
    })
    vim.fn.timer_start(timeout_ms + 1000, function()
        if not done then
            finish(nil)
        end
    end)
end

local function get_local_tag(callback)
    git.git({ "describe", "--tags", "--abbrev=0" }, function(res)
        if not res or res.code ~= 0 or not res.stdout then
            callback(nil)
            return
        end
        callback(vim.trim(res.stdout))
    end)
end

function M.check_update()
    local now = vim.uv.now()
    if cache.remote_tag and (now - cache.timestamp) < CACHE_TTL then
        get_local_tag(function(local_tag)
            if not local_tag then return end
            if cache.remote_tag == local_tag then
                utils.notify(string.format("adev.nvim: %s", local_tag))
            elseif version_greater(cache.remote_tag, local_tag) then
                utils.notify(
                    string.format("Update available: %s → %s", local_tag, cache.remote_tag),
                    vim.log.levels.WARN
                )
            else
                utils.notify(string.format("adev.nvim: %s", local_tag))
            end
        end)
        return
    end
    fetch_and_get_tag(function(remote_tag)
        if not remote_tag then
            cache.remote_tag = nil
            utils.notify("adev.nvim: Unable to check updates (no network)", vim.log.levels.WARN)
            return
        end
        local cache = { remote_tag = remote_tag, timestamp = now }
        get_local_tag(function(local_tag)
            if not local_tag then return end
            if remote_tag == local_tag then
                utils.notify(string.format("adev.nvim: %s", local_tag))
            elseif version_greater(remote_tag, local_tag) then
                utils.notify(
                    string.format("Update available: %s → %s", local_tag, remote_tag),
                    vim.log.levels.WARN
                )
            else
                utils.notify(string.format("adev.nvim: %s", local_tag))
            end
        end)
    end)
end

function M.update()
    local now = vim.uv.now()
    local use_cache = cache.remote_tag and (now - cache.timestamp) < CACHE_TTL
    local remote_tag = use_cache and cache.remote_tag or nil
    local function proceed(tag)
        if not tag then
            utils.err_notify("Failed to get remote tag")
            return
        end
        get_local_tag(function(local_tag)
            if not local_tag then return end
            if remote_tag == local_tag then
                utils.notify(string.format("adev.nvim is up to date on main"))
            end
            local update_branch = "update/" .. remote_tag
            git.git({ "checkout", "-B", update_branch, remote_tag }, function(res)
                if res and res.code == 0 then
                    if remote_tag ~= local_tag then
                        utils.notify(string.format("Updated to %s", remote_tag))
                        vim.schedule(function()
                            require("adev.onboarding"):onboarding()
                        end)
                        git.git({ "branch", "--list", "update/*" }, function(branch_res)
                            if branch_res and branch_res.code == 0 and branch_res.stdout then
                                for old_branch in vim.gsplit(branch_res.stdout, "\n", { plain = true }) do
                                    old_branch = vim.trim(old_branch)
                                    if old_branch ~= "" and old_branch ~= update_branch then
                                        vim.fn.jobstart({ "git", "branch", "-D", old_branch }, {
                                            on_exit = function() end
                                        })
                                    end
                                end
                            end
                        end)
                    end
                else
                    utils.err_notify(string.format("Failed to update to %s", remote_tag))
                end
            end)
        end)
    end
    if use_cache then
        proceed(remote_tag)
    else
        fetch_and_get_tag(function(tag)
            if tag then
                cache = { remote_tag = tag, timestamp = now }
            end
            proceed(tag)
        end)
    end
end

return M
