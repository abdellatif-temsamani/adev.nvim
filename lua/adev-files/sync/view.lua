local index = require "adev-files.sync.index"
local render = require "adev-files.file_manager.render"
local roots = require "adev-files.file_manager.roots"
local window = require "adev-files.file_manager.window"
local state = require "adev-files.state"

local M = {}

---@param buf integer
---@return string|nil
local function resolve_root(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    local prefix = "adev-files://"
    if name:sub(1, #prefix) ~= prefix then
        return nil
    end
    local root = name:sub(#prefix + 1)
    return roots.normalize_root(root)
end

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
    render.add_virtual_text(buf, st.root)
end

---@param buf integer
---@return boolean, string?
function M.discard_reset(buf)
    local st = state.get(buf)
    if st and st.applying then
        return false, "changes are being applied"
    end
    if not st then
        local root = resolve_root(buf)
        if not root then
            return false, "missing root for discard"
        end
        st = state.init(buf, root)
    end

    st.root = roots.normalize_root(st.root)
    state.clear_pending_ops(buf)
    pcall(vim.api.nvim_buf_set_name, buf, "adev-files://" .. (st.root or "./"))
    local ok, manager_win = pcall(vim.api.nvim_buf_get_var, buf, "adev_files_win")
    if ok and manager_win then
        window.set_title(manager_win, st.root)
    end
    render.render(buf, st.root)
    index.index_original(buf)
    index.reindex(buf)
    render.add_virtual_text(buf, st.root)
    return true
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
    render.add_virtual_text(buf, st.root)
end

return M
