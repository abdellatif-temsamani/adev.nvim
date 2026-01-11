local utils = require "adev-common.utils"

local M = {}

function M.git(args, callback)
    local cmd = vim.list_extend({ Adev.git }, args)
    local process = vim.system(cmd, {
        cwd = utils.files.adev_path,
        text = true,
    }, callback)
    if not callback then
        return process:wait()
    end
end

function M.get_version(callback)
    if callback then
        M.git({ "describe", "--tags", "--abbrev=0" }, function(res)
            callback(res and res.stdout and vim.trim(res.stdout) or nil)
        end)
    else
        local res = M.git { "describe", "--tags", "--abbrev=0" }
        return res and res.stdout and vim.trim(res.stdout) or nil
    end
end

function M.get_branch(callback)
    if callback then
        M.git({ "rev-parse", "--abbrev-ref", "HEAD" }, function(res)
            callback(res and res.stdout and vim.trim(res.stdout) or nil)
        end)
    else
        local res = M.git { "rev-parse", "--abbrev-ref", "HEAD" }
        return res and res.stdout and vim.trim(res.stdout) or nil
    end
end

function M.get_available_versions(callback)
    if callback then
        M.git({ "tag", "--list", "--sort=-creatordate" }, function(res)
            if not res or res.code ~= 0 then
                callback(nil)
                return
            end
            local versions = vim.tbl_filter(function(v)
                return v ~= ""
            end, vim.split(res.stdout, "\n"))
            callback(#versions > 0 and versions or nil)
        end)
    else
        local res = M.git { "tag", "--list", "--sort=-creatordate" }
        if not res or res.code ~= 0 then
            return nil
        end
        local versions = vim.tbl_filter(function(v)
            return v ~= ""
        end, vim.split(res.stdout, "\n"))
        return #versions > 0 and versions or nil
    end
end

return M
