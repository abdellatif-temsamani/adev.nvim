local Utils = {}

--- Displays a notification to the user.
---@param msg string Content of the notification to show to the user.
---@param level integer|nil One of the values from |vim.log.levels|.
---@diagnostic disable-next-line: unused-local
function Utils.adev_notify(msg, level)
    vim.notify(msg, level, {
        title = vim.g.Adev._NAME,
    })
end

return Utils
