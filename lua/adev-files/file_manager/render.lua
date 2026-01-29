local M = {}

local listing = require "adev-files.file_manager.listing"

---@param buf integer
---@param root string
function M.render(buf, root)
    local lines = listing.build_lines(root)

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false
end

return M
