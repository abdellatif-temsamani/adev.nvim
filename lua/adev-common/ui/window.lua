local M = {}

--- creates a buffer with content
--- @param content string[]
--- @param listed boolean Sets 'buflisted'
--- @param scratch boolean Creates a "throwaway" `scratch-buffer` for temporary work
--- @return integer buf
function M.create_buf(content, listed, scratch)
    local buf = vim.api.nvim_create_buf(listed, scratch)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    return buf
end

--- @class FloatingWinOpts
--- @field width? integer
--- @field height? integer

--- @class FloatingWinOpts
M.floating_defaults = {
    width = 40,
    height = 5,
}

--- create a floating window for a buffer
---@param buf integer buffer id
---@param opts? FloatingWinOpts
function M:new_floating(buf, opts)
    --- @class FloatingWinOpts
    opts = vim.tbl_deep_extend("force", {}, self.floating_defaults, opts or {})

    return vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = opts.width,
        height = opts.height,
        row = math.floor((vim.o.lines - opts.height) / 2),
        col = math.floor((vim.o.columns - opts.width) / 2),
        style = "minimal",
        border = Adev.ui.border,
    })
end

return M
