local setup = require "adev.setup"

local M = {}

M._VERSION = "2.3.0"

---@param opts SetupOpts
function M.setup(opts)
    setup.setup(opts)
end

return M
