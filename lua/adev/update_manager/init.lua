local local_check_update = require "adev.update_manager.check_update"
local local_update = require "adev.update_manager.update"
local utils = require "adev-common.utils"

--- @alias GitCmd fun(cmd: string[], opts: vim.SystemOpts, on_exit: fun(out: vim.SystemCompleted)?): vim.SystemObj

---@param cmd string[]
---@param opts vim.SystemOpts
---@param on_exit fun(out: vim.SystemCompleted)?
---@return vim.SystemObj
local function git_cmd(cmd, opts, on_exit)
    local gitcmd = { Adev.git }

    for _, v in ipairs(cmd) do
        table.insert(gitcmd, v)
    end
    return vim.system(
        gitcmd,
        vim.tbl_extend("force", opts, {
            cwd = utils.adev_path,
        }),
        on_exit
    )
end

local UpdateManager = {}

UpdateManager.check_update = function()
    local_check_update(git_cmd, UpdateManager.get_branch())
end

UpdateManager.update = function()
    local_update(git_cmd, UpdateManager.get_branch())
end

--- Get the current version of adev.nvim
---@return string
function UpdateManager.get_version()
    local local_tag_res = git_cmd({
        "describe",
        "--tags",
        "--abbrev=0",
    }, {
        text = true,
    }):wait()

    local local_tag = local_tag_res.stdout:gsub("%s+", "")
    return local_tag
end

--- Get the current branch of adev.nvim
---@return string
function UpdateManager.get_branch()
    local local_branch_res = git_cmd({
        "rev-parse",
        "--abbrev-ref",
        "HEAD",
    }, {
        text = true,
    }):wait()

    local local_branch = local_branch_res.stdout:gsub("%s+", "")
    return local_branch
end

return UpdateManager
