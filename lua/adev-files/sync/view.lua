local clipboard = require "adev-files.clipboard"
local git = require "adev-files.git"
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
    local root = name:sub(#prefix + 1):gsub("#%d+$", "")
    return roots.normalize_root(root)
end

--- Fetch git status asynchronously and re-render virtual text
---@param buf integer
local function refresh_git_status(buf)
    local st = state.get(buf)
    if not st then
        return
    end
    local root = st.root
    git.fetch_status(root, function(status)
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        local s = state.get(buf)
        if not s or s.root ~= root then
            return
        end
        state.set_git_status(buf, status)
        render.add_virtual_text(buf, root)
    end)
end

---@param buf integer
function M.refresh(buf)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end
    state.set_git_status(buf, nil)
    pcall(vim.api.nvim_buf_set_name, buf, "adev-files://" .. (st.root or "./"))
    render.render(buf, st.root)
    index.index_original(buf)
    index.reindex(buf)
    render.add_virtual_text(buf, st.root)
    refresh_git_status(buf)
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
    clipboard.clear()
    state.clear_pending_ops(buf)
    state.set_git_status(buf, nil)
    pcall(vim.api.nvim_buf_set_name, buf, "adev-files://" .. (st.root or "./"))
    window.set_title_from_state(buf, st.root)
    render.render(buf, st.root)
    index.index_original(buf)
    index.reindex(buf)
    render.add_virtual_text(buf, st.root)
    refresh_git_status(buf)
    return true
end

---@param buf integer
function M.toggle_hidden(buf)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end
    st.show_hidden = not st.show_hidden
    render.render(buf, st.root)
    index.index_original(buf)
    index.reindex(buf)
    render.add_virtual_text(buf, st.root)
end

---@param buf integer
---@param root string
function M.set_root(buf, root)
    local st = state.get(buf)
    if not st or st.applying then
        return
    end
    st.root = roots.normalize_root(root)
    state.set_git_status(buf, nil)
    pcall(vim.api.nvim_buf_set_name, buf, "adev-files://" .. st.root)
    window.set_title_from_state(buf, st.root)
    render.render(buf, st.root)
    index.index_original(buf)
    index.reindex(buf)
    render.add_virtual_text(buf, st.root)
    refresh_git_status(buf)
end

return M
