local events = require "adev-common.utils.events"

local M = {}

function M.file_events()
    return { events.buffer.new_file, events.buffer.read_pre, events.file.read_pre }
end

---@return boolean
function M.is_git_worktree()
    local git = Adev and Adev.git or "git"
    local res = vim.system({ git, "rev-parse", "--is-inside-work-tree" }, {
        text = true,
    }):wait()

    return res and res.code == 0 and vim.trim(res.stdout or "") == "true"
end

return M
