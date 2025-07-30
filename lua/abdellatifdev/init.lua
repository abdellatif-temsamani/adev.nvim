---@class M
---@field _NAME string
---@field _AUTHOR string
---@field _VERSION string
---@field git "git" | string
local M = {
    _NAME = "Adev.nvim",
    _AUTHOR = "Abdellatif Dev",
    _VERSION = "1.1.0",

    git = "git"
}

---Display author and version information using `vim.notify`.
---
---This is primarily for debugging or user reference.
function M:info()
    vim.notify(
        self._NAME .. "\n" ..
        "Author: " .. self._AUTHOR .. "\n" ..
        "Version: " .. self._VERSION,
        vim.log.levels.INFO
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
function M:setup_commands()
    vim.api.nvim_create_user_command("ADInfo", function() self:info() end, { desc = "info about Adev distro" })
    vim.api.nvim_create_user_command("ADUpdate", function()
        require("abdellatifdev.utils").update_adev(self.git)
    end, {
        desc = "Update Neovim config by git pulling ~/.config/nvim",
    })
end

---Setup Neovim core settings and bootstrap plugins.
---
---This function enables Lua module caching, configures UI options,
---sets key mapping leaders, and initializes lazy.nvim plugin manager.
---@param opts? { clommands?: boolean, git: "git" | string }
function M:setup(opts)
    opts = opts or {
        commands = true,
        git = "git"
    }

    if vim.fn.executable(self.git) == 0 then
        vim.notify(self.git .. " executable not found in PATH!", vim.log.levels.ERROR)
    end

    vim.loader.enable(true)
    vim.o.winbar = " "
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "

    require("abdellatifdev.utils").setup_lazy(self.git)

    vim.opt.termguicolors = true
    if opts.commands == true then
        self:setup_commands()
    end
end

return M
