local events = require "adev-common.utils.events"

local M = {}

---@param lsp_map table
function M.setup(lsp_map)
    for lsp, fts in pairs(lsp_map) do
        vim.api.nvim_create_autocmd({ events.buffer.read_post, events.buffer.new_file }, {
            group = vim.api.nvim_create_augroup(string.format("adev_%s", lsp), { clear = true }),
            callback = function(args)
                local ft = vim.bo[args.buf].filetype
                if vim.tbl_contains(fts, ft) then
                    vim.schedule(function()
                        vim.lsp.enable(lsp)
                    end)
                end
            end,
        })
    end
end

return M
