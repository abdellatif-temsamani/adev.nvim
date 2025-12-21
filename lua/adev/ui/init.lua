local utils = require "adev.utils"
local ui = vim.ui

local Ui = {}

---@param prompt string
local function wrap_prompt(prompt)
    return string.format("Adev >> %s: ", prompt)
end

---@class InputOpts
---@field prompt string
---@field on_confirm fun(item: string): nil

---@class SelectOpts: InputOpts
---@field on_confirm fun(item ): nil

---@param opts InputOpts
function Ui.input(opts)
    local defaults = {

        prompt = "",
        on_confirm = function(item)
            utils.notify(item)
        end,
    }

    ---@type InputOpts
    opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    ui.input({ prompt = wrap_prompt(opts.prompt) }, opts.on_confirm)
end

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
