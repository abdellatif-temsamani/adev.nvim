local updateManager = require "adev.utils.update"
local utils = require "adev.utils"

--- Sets up custom user commands for the Adev module.
---@return nil
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
                updateManager.update_adev()
            end, {
                desc = "Update " .. name,
            })

            create_command("ADCheckUpdate", function()
                updateManager.check_adev_update()
            end, {
                desc = "Check if " .. name .. "has an update",
            })
        end,
    })
end

return { register = register }
