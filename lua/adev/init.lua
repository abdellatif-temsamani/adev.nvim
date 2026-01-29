local setup = require "adev.setup"

local M = {}

---@param opts SetupOpts
function M.setup(opts)
    setup.setup(opts)
end

return M
