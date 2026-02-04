local index = require "adev-files.sync.index"
local render = require "adev-files.file_manager.render"
local roots = require "adev-files.file_manager.roots"
local window = require "adev-files.file_manager.window"
local state = require "adev-files.state"

local M = {}

---@param buf integer
function M.refresh(buf)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end
    pcall(vim.api.nvim_buf_set_name, buf, "adev-files://" .. (st.root or "./"))
    render.render(buf, st.root)
    index.index_original(buf)
    index.reindex(buf)
end

---@param buf integer
---@param root string
function M.set_root(buf, root)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end
    st.root = roots.normalize_root(root)
    pcall(vim.api.nvim_buf_set_name, buf, "adev-files://" .. st.root)
    local ok, manager_win = pcall(vim.api.nvim_buf_get_var, buf, "adev_files_win")
    if ok and manager_win then
        window.set_title(manager_win, st.root)
    end
    render.render(buf, st.root)
    index.index_original(buf)
    index.reindex(buf)
end

return M
