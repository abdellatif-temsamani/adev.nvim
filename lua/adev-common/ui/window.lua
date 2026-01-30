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
    vim.keymap.set("", "q", "<cmd>bwipeout<CR>", { buffer = opts.buf })

    if Snacks then
        Snacks.win(opts)
    else
        -- fallback
        local ui = vim.api.nvim_list_uis()[1]
        local width = opts.width or 60
        local height = opts.height or 2
        if ui then
            width = math.min(width, ui.width)
            height = math.min(height, ui.height)
        end

        local win_opts = {
            relative = "editor", -- Relative to the whole editor
            width = width,
            height = height,
            row = ui and math.floor((ui.height - height) / 2) or 0,
            col = ui and math.floor((ui.width - width) / 2) or 0,
            border = opts.border,
            title = opts.title,
            -- you can also customize colors with winhl
        }

        if win_opts.row < 0 then
            win_opts.row = 0
        end
        if win_opts.col < 0 then
            win_opts.col = 0
        end

        vim.api.nvim_open_win(opts.buf, true, win_opts)
    end
end

return M
