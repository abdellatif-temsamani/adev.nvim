local M = {}

-- require "snacks.win"
---@type snacks.win.Config
M.floating_defaults = {
    title = "adev.nvim",
    width = 40,
    height = 5,
    border = Adev and Adev.ui.border or "single",
}

--- create a floating window for a buffer
---@param opts snacks.win.Config
function M.floating_window(opts)
    ---@type snacks.win.Config
    opts = vim.tbl_deep_extend("force", {}, M.floating_defaults, opts or {})
    vim.keymap.set({ "n", "v" }, "q", "<cmd>bwipeout<CR>", { buffer = opts.buf })

    if Snacks then
        Snacks.win(opts)
    else
        -- fallback
        local win_opts = {
            relative = "editor", -- Relative to the whole editor
            width = 60,
            height = 2,
            row = (vim.api.nvim_list_uis()[1].height - 2) / 2,
            col = (vim.api.nvim_list_uis()[1].width - 60) / 2,
            border = opts.border,
            title = opts.title,
            -- you can also customize colors with winhl
        }

        vim.api.nvim_open_win(opts.buf, true, win_opts)
    end
end

return M
