local adev_notify = require("adev.utils").adev_notify
local UdateManager = {}

--- Update the Adev.nvim configuration by performing a git pull.
---
function UdateManager.update_adev()
    local config_path = vim.fn.stdpath "config"
    local git_cmd = { "git", "pull", "--ff-only" }

    local stderr_lines = {}

    vim.fn.jobstart(git_cmd, {
        cwd = config_path,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data, _)
            if data then
                local lines = vim.tbl_filter(function(line)
                    return line and line ~= ""
                end, data)

                if #lines > 0 then
                    local msg = table.concat(lines, "\n")
                    if msg:find "Already up to date" then
                        adev_notify("Already up to date", vim.log.levels.INFO)
                    else
                        adev_notify("Updated successfully:\n" .. msg, vim.log.levels.INFO)
                    end
                end
            end
        end,
        on_stderr = function(_, data, _)
            if data then
                for _, line in ipairs(data) do
                    if line and line ~= "" then
                        table.insert(stderr_lines, line)
                    end
                end
            end
        end,
        on_exit = function(_, code, _)
            if code ~= 0 then
                local msg = table.concat(stderr_lines, "\n")
                if msg == "" then
                    msg = "Unknown error"
                end
                adev_notify("Git pull failed:\n" .. msg, vim.log.levels.ERROR)
            end
        end,
    })
end

--- Checks if Adev.nvim has updates from its GitHub remote.
---@return nil
function UdateManager.check_adev_update()
    local config_path = vim.fn.stdpath "config"

    -- Step 1: fetch remote refs
    vim.system({ "git", "-C", config_path, "fetch", "origin" }, { text = true }, function(fetch_result)
        if fetch_result.code ~= 0 then
            vim.schedule(function()
                adev_notify("Failed to fetch updates: " .. (fetch_result.stderr or ""), vim.log.levels.ERROR)
            end)
            return
        end

        -- Step 2: get current branch
        vim.system(
            { "git", "-C", config_path, "rev-parse", "--abbrev-ref", "HEAD" },
            { text = true },
            function(branch_result)
                if branch_result.code ~= 0 then
                    return
                end
                local branch = (branch_result.stdout or ""):gsub("%s+", "")

                -- Step 3: check how many commits we're behind
                vim.system(
                    { "git", "-C", config_path, "rev-list", branch .. "..origin/" .. branch, "--count" },
                    { text = true },
                    function(check_result)
                        if check_result.code ~= 0 then
                            vim.schedule(function()
                                adev_notify(
                                    "Failed to check updates: " .. (check_result.stderr or ""),
                                    vim.log.levels.ERROR
                                )
                            end)
                            return
                        end

                        local updates = tonumber((check_result.stdout or ""):match "%d+") or 0
                        vim.schedule(function()
                            if updates > 0 then
                                adev_notify(
                                    "There are " .. updates .. " new commits available in your config!",
                                    vim.log.levels.INFO
                                )
                            else
                                adev_notify("Adev is up-to-date.", vim.log.levels.INFO)
                            end
                        end)
                    end
                )
            end
        )
    end)
end

---Display author and version information.
---This is primarily for debugging or user reference.
function UdateManager.info()
    local info = vim.g.Adev
    local function nvim_version()
        local v = vim.version()
        return string.format("%d.%d.%d", v.major, v.minor, v.patch)
    end

    local function git_branch()
        local config_dir = vim.fn.stdpath "config"

        local handle = io.popen(string.format("git -C %s rev-parse --abbrev-ref HEAD 2>/dev/null", config_dir))
        if handle then
            local result = handle:read "*a"
            handle:close()
            result = result:gsub("%s+", "") -- remove any trailing newline
            if result == "" then
                return "N/A"
            end
            return result
        else
            return "N/A"
        end
    end

    local lines = {
        ("`Name`:    %s"):format(info._NAME),
        ("`Version`: %s"):format(info._VERSION),
        ("`Author`:  %s"):format(info._AUTHOR),
        ("`Neovim`:  %s"):format(nvim_version()),
        ("`LuaJIT`:  %s"):format(_VERSION),
        ("`Git`:     %s"):format(git_branch()),
    }

    adev_notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

return UdateManager
