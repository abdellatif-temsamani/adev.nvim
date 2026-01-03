local utils = require "adev.utils"
local ui = vim.ui

local Ui = {}

---@param prompt string
local function wrap_prompt(prompt)
    return string.format("[Adev] %s: ", prompt)
end

---@class SelectOpts
---@field prompt string
---@field on_confirm fun(item): nil

--- @param prompt string
--- @param default string
--- @param completion string
--- @param on_confirm fun(item): nil
function Ui.input(prompt, default, completion, on_confirm)
    vim.ui.input({
        prompt = "[adev.files]: " .. prompt,
        default = default,
        completion = completion,
    }, on_confirm)
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
