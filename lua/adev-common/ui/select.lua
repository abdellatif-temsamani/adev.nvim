---@class SelectOpts
---@field title? string

---@type SelectOpts
local defaults = {
    title = "adev.nvim",
}

---@param prompt string
---@param items any[]
---@param on_choice fun(item: any|nil, idx: integer|nil): nil
---@param opts? SelectOpts
return function(prompt, items, on_choice, opts)
    ---@type SelectOpts
    opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    vim.ui.select(items, {
        prompt = "[" .. opts.title .. "]: " .. prompt,
    }, on_choice)
end
