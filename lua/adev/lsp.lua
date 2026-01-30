local autocmds = require "adev.lsp.autocmds"
local lsp_map = require "adev.lsp.maps"
local servers = require "adev.lsp.servers"

local M = {}

function M.setup()
    autocmds.setup(lsp_map)
end

function M.setup_servers()
    servers.setup()
end

M.lsp_map = lsp_map
M.keys = vim.tbl_keys(lsp_map)

return M
