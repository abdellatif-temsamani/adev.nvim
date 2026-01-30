local parse = require "adev-files.parse"
local state = require "adev-files.state"

local M = {}

---@param root string
---@param fs_name string
---@return string
local function join(root, fs_name)
    return root .. fs_name
end

---@param buf integer
function M.reindex(buf)
    local st = state.get(buf)
    if not st then
        return
    end

    local ns = state.ns()
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    local marks = {}
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    for i = 1, #lines do
        local entry, err = parse.parse_line(lines[i])
        if err then
            -- leave the line untracked; we never want to do destructive ops
            -- when we can't parse an existing entry.
        elseif entry then
            local id = vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { right_gravity = false })
            marks[id] = {
                kind = entry.kind,
                name = entry.name,
                fs_name = entry.fs_name,
                abs_path = join(st.root, entry.fs_name),
            }
        end
    end

    state.set_marks(buf, marks)
end

return M
