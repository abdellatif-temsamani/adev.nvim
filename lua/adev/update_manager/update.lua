local utils = require "adev.utils"

---@param git_cmd fun(cmd: string[], opts: vim.SystemOpts): vim.SystemObj
---@param branch string
return function(git_cmd, branch)
    branch = branch or "main" -- default to main if branch not provided

    -- Step 1: Fetch all remote tags
    local fetch_res = git_cmd({ "fetch", "--tags" }, { text = true }):wait()
    if fetch_res.code ~= 0 then
        utils.err_notify "Failed to fetch tags"
        return
    end

    -- Step 2: Get latest remote tag for the current branch
    local remote_ref = "origin/" .. branch
    local remote_res = git_cmd({ "describe", "--tags", "--abbrev=0", remote_ref }, { text = true }):wait()
    if remote_res.code ~= 0 then
        utils.err_notify("Failed to get remote tag for " .. remote_ref)
        return
    end
    local remote_tag = vim.trim(remote_res.stdout)

    -- Step 3: Get latest local tag
    local local_res = git_cmd({ "describe", "--tags", "--abbrev=0" }, { text = true }):wait()
    if local_res.code ~= 0 then
        utils.err_notify "Failed to get local tag"
        return
    end
    local local_tag = vim.trim(local_res.stdout)

    -- Step 4: Compare and act
    if remote_tag == local_tag then
        utils.notify("adev.nvim is up to date on branch " .. branch)
    else
        utils.notify(
            "adev.nvim update available on " .. branch .. ": " .. remote_tag,
            vim.log.levels.WARN
        )

        -- Optional: automatically update to the remote tag
        local checkout_res = git_cmd({ "checkout", remote_tag }, { text = true }):wait()
        if checkout_res.code == 0 then
            utils.notify("Updated to " .. remote_tag)

            local onboard = require "adev.onboarding"
            onboard:onboarding()
        else
            utils.err_notify("Failed to update to " .. remote_tag)
        end
    end
end
