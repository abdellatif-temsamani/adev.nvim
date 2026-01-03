---@class InputOpts
---@field default string
---@field completion string
---@field title string

---@type InputOpts
local defaults = {
    title = "adev.nvim",
    completion = "",
    default = "",
}

---@param prompt string
---@param on_confirm fun(item): nil
---@param opts InputOpts
return function(prompt, opts, on_confirm)
    ---@type InputOpts
    opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    Snacks.input.input({
        prompt = "[" .. opts.title .. "]: " .. prompt,
        default = opts.default,
        completion = opts.completion,
    }, on_confirm)
end
