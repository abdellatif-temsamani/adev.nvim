local M = {}

---@type snacks.win.Config
M.floating_defaults = {
    title = "adev.nvim",
    width = 40,
    height = 5,
}

--- create a floating window for a buffer
---@param opts snacks.win.Config
function M.floating_window(opts)
    ---@type snacks.win.Config
    opts = vim.tbl_deep_extend("force", {}, M.floating_defaults, opts or {})
    assert(opts.buf, "floating_window requires opts.buf")
    vim.keymap.set("", "q", "<cmd>bwipeout<CR>", { buffer = opts.buf })

    -- Resolve border at call time so Adev config is available
    local border = (Adev and Adev.ui and Adev.ui.border) or opts.border or "single"

    if Snacks then
        opts.border = border
        Snacks.win(opts)
    else
        -- fallback
        local ui = vim.api.nvim_list_uis()[1]
        local width = opts.width or 60
        local height = opts.height or 2
        if ui then
            -- Support fractional (0-1) values as proportions of the editor
            if width > 0 and width < 1 then
                width = math.floor(ui.width * width)
            end
            if height > 0 and height < 1 then
                height = math.floor(ui.height * height)
            end
            width = math.max(1, math.min(width, ui.width))
            height = math.max(1, math.min(height, ui.height))
        end

        local win_opts = {
            relative = "editor",
            width = width,
            height = height,
            row = ui and math.floor((ui.height - height) / 2) or 0,
            col = ui and math.floor((ui.width - width) / 2) or 0,
            border = border,
            title = opts.title,
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
