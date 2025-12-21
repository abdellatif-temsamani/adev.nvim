local changelog = require "adev.changelog"
local onboarding = require "adev.onboarding"
local update_manager = require "adev.update_manager"

local M = {
    commands = {
        {
            name = "ADUpdate",
            command = update_manager.update,
            opts = { desc = "Update adev" },
        },
        {
            name = "ADConfig",
            command = onboarding.edit_config,
            opts = { desc = "Edit Adev configuration file" },
        },
        {
            name = "ADUpdateCheck",
            command = update_manager.check_update,
            opts = { desc = "Check for updates" },
        },
        {
            name = "ADChangelog",
            command = changelog.show_changelog,
            opts = {
                desc = "Show changelog for current or specified version",
                nargs = "?",
                complete = function(arg_lead)
                    local versions = changelog.get_available_versions()
                    if not versions then
                        return {}
                    end

                    local matches = {}
                    for _, version in ipairs(versions) do
                        if version:find(arg_lead, 1, true) == 1 then
                            table.insert(matches, version)
                        end
                    end
                    return matches
                end,
            },
        },
        {
            name = "ADVersions",
            command = changelog.list_versions,
            opts = { desc = "List available versions" },
        },
    },
}

--- Helper to create a user command
---@param name string
--- @param callback string|fun(args: vim.api.keyset.create_user_command.command_args)
--- @param opts vim.api.keyset.user_command Optional `command-attributes`.
function M:create_user_command(name, callback, opts)
    vim.api.nvim_create_user_command(name, callback, opts)
end

-- Setup all commands
function M:setup()
    for _, command in ipairs(self.commands) do
        self:create_user_command(command.name, command.command, command.opts)
    end
end

return M
