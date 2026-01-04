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

return M
