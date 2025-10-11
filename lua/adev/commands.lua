local utils = require "adev.utils"
--- Sets up custom user commands for the Adev module.
---
--- Creates the following Neovim user commands:
--- - `:ADInfo` — Calls `self:info()` to show information about the Adev distro.
--- - `:ADUpdate` — Runs the asynchronous update function `update_adev` from `abdellatifdev.utils`
---   to pull updates from the git repository located in `~/.config/nvim`.
---
--- Both commands include descriptive `desc` fields for `:help` and completion.
local function register()
    local create_command = vim.api.nvim_create_user_command
    local name = vim.g.Adev._NAME

    vim.api.nvim_create_autocmd("CmdlineEnter", {
        desc = "Register Adev custom commands",
        once = true,
        callback = function()
            create_command("ADInfo", function()
                utils.info()
            end, { desc = "info about " .. name })

            create_command("ADUpdate", function()
                utils.update_adev()
            end, {
                desc = "Update " .. name,
            })

            create_command("ADCheckUpdate", function()
                utils.check_adev_update()
            end, {
                desc = "Check if " .. name .. "has an update",
            })
        end,
    })
end


return { register = register }
