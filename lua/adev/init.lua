---@class M
---@field _NAME string
---@field _AUTHOR string
---@field _VERSION string
---@field git "git" | string
local M = {
    _NAME = "Adev.nvim",
    _AUTHOR = "Abdellatif Dev",
    _VERSION = "1.4.0",
}

---Display author and version information using `vim.notify`.
---
---This is primarily for debugging or user reference.
function M:info()
    local function nvim_version()
        local v = vim.version()
        return string.format("%d.%d.%d", v.major, v.minor, v.patch)
    end

    local lines = {
        ("`Name`:    %s"):format(self._NAME),
        ("`Version`: %s"):format(self._VERSION),
        ("`Author`:  %s"):format(self._AUTHOR),
        ("`Neovim`:  %s"):format(nvim_version()),
        ("`LuaJIT`:  %s"):format(_VERSION),
    }

    vim.notify(
        table.concat(lines, "\n"),
        vim.log.levels.INFO,
        { title = self._NAME or "Adev info" }
    )
end

--- Sets up custom user commands for the Adev module.
---
--- Creates the following Neovim user commands:
--- - `:ADInfo` — Calls `self:info()` to show information about the Adev distro.
--- - `:ADUpdate` — Runs the asynchronous update function `update_adev` from `abdellatifdev.utils`
---   to pull updates from the git repository located in `~/.config/nvim`.
---
--- Both commands include descriptive `desc` fields for `:help` and completion.
local function setup_commands()
    vim.api.nvim_create_autocmd("CmdlineEnter", {
        desc = "Register Adev custom commands",
        once = true,
        callback = function()
            vim.api.nvim_create_user_command("ADInfo", function()
                M:info()
            end, { desc = "info about Adev distro" })

            vim.api.nvim_create_user_command("ADUpdate", function()
                require("adev.utils").update_adev()
            end, {
                desc = "Update Neovim config by git pulling ~/.config/nvim",
            })
        end,
    })
end

---Setup Neovim core settings and bootstrap plugins.
---
---This function enables Lua module caching, configures UI options,
---sets key mapping leaders, and initializes lazy.nvim plugin manager.
function M.setup()
    require("adev.utils").setup_lazy()
    setup_commands()

    vim.cmd [[ colorscheme catppuccin-mocha ]]
end

return M
