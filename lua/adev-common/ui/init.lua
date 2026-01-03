local utils = require "adev-common.utils"
local ui = vim.ui

local Ui = {
    input = require "adev-common.ui.input",
}

---@param prompt string
local function wrap_prompt(prompt)
    return string.format("[Adev] %s: ", prompt)
end

---@class SelectOpts
---@field prompt string
---@field on_confirm fun(item): nil

---@generic T
---@param items T[]
---@param opts SelectOpts<T>
---@return nil
function Ui.select(items, opts)
    local defaults = {
        items = {},
        prompt = "",
        on_confirm = function(item)
            utils.notify(vim.inspect(item))
        end,
    }

    opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    ui.select(items, { prompt = wrap_prompt(opts.prompt) }, opts.on_confirm)
end

return Ui
