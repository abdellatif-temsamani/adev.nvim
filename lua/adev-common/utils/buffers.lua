local M = {}
---@class BufOpts
---@field listed? boolean Sets 'buflisted'
---@field scratch? boolean Creates a "throwaway" `scratch-buffer` for temporary work
---@field bo? vim.bo vim.bo options
M.buf_defaults = {
    listed = false,
    scratch = true,
    bo = {},
}

--- creates a buffer with content
---@param content string[] content to be written in the buffer
---@param opts? BufOpts opts for the buffer
---@return integer buf - buffer id
function M.create(content, opts)
    ---@type BufOpts
    opts = vim.tbl_deep_extend("force", {}, M.buf_defaults, opts or {})

    local buf = vim.api.nvim_create_buf(opts.listed, opts.scratch)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

    vim.iter(opts.bo):each(
    ---@param key vim.bo
    ---@param value string|boolean|integer|number
        function(key, value)
            vim.bo[buf][key] = value
        end
    )

    return buf
end

return M
