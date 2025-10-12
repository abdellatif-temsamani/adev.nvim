local Utils = {}

--- Displays a notification to the user.
---@param msg string Content of the notification to show to the user.
---@param level integer|nil One of the values from |vim.log.levels|.
---@diagnostic disable-next-line: unused-local
function Utils.adev_notify(msg, level)
    vim.notify(msg, level, {
        title = (vim.g.Adev and vim.g.Adev._NAME) or "Adev.nvim",
    })
end

---Display author and version information.
---This is primarily for debugging or user reference.
function Utils.info()
    local info = vim.g.Adev or {
        _NAME = "Adev.nvim",
        _VERSION = "1.5.0",
        _AUTHOR = "Abdellatif Dev"
    }
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
        ("`Branch`:     %s"):format(git_branch()),
    }

    Utils.adev_notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

return Utils
