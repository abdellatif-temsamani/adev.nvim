local utils = require "adev-common.utils"

---@param git_cmd GitCmd
---@param branch string
return function(git_cmd, branch)
    -- Step 1: Fetch all remote tags asynchronously
    git_cmd({ "fetch", "--tags" }, { text = true }, function(fetch_res)
        if fetch_res.code ~= 0 then
            utils.err_notify "Failed to fetch tags"
            return
        end

        -- Step 2: Get latest remote tag for current branch
        local remote_ref = string.format("origin/%s", branch or "main")

        git_cmd(
            { "describe", "--tags", "--abbrev=0", remote_ref },
            { text = true },
            function(remote_res)
                if remote_res.code ~= 0 then
                    utils.err_notify("Failed to get remote tag for " .. remote_ref)
                    return
                end

                local remote_tag = vim.trim(remote_res.stdout)

                -- Step 3: Get latest local tag
                git_cmd({ "describe", "--tags", "--abbrev=0" }, { text = true }, function(local_res)
                    if local_res.code ~= 0 then
                        utils.err_notify "Failed to get local tag"
                        return
                    end

                    local local_tag = vim.trim(local_res.stdout)

                    -- Step 4: Compare and notify
                    if remote_tag == local_tag then
                        utils.notify(
                            string.format("adev.nvim version: %s on branch %s", local_tag, branch)
                        )
                    else
                        utils.notify(
                            string.format(
                                "adev.nvim update available on %s: %s",
                                branch,
                                remote_tag
                            ),
                            vim.log.levels.WARN
                        )
                    end
                end)
            end
        )
    end)
end
