local git = require "adev-common.git"

local M = {}

local cache = { tag = nil, timestamp = nil }
local CACHE_TTL = 300000

function M.get_cached(now)
    if cache.tag and (now - cache.timestamp) < CACHE_TTL then
        return cache.tag
    end
end

function M.fetch_latest(cb, now)
    local stamp = now or vim.uv.now()
    git.git({ "fetch", "--tags", "-q" }, function()
        git.get_available_versions(function(versions)
            local tag = versions and #versions > 0 and versions[1] or nil
            if tag then
                cache = { tag = tag, timestamp = stamp }
            end
            cb(tag)
        end)
    end)
end

return M
