local clipboard = require "adev-files.clipboard"
local git = require "adev-files.git"
local index = require "adev-files.sync.index"
local listing = require "adev-files.file_manager.listing"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local roots = require "adev-files.file_manager.roots"
local state = require "adev-files.state"
local utils = require "adev-common.utils"
local window = require "adev-files.file_manager.window"

local M = {}

local function resolve_root(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    local prefix = "adev-files://"
    if name:sub(1, #prefix) ~= prefix then
        return nil
    end
    return roots.normalize_root(name:sub(#prefix + 1):gsub("#%d+$", ""))
end

---@param buf integer
---@return boolean
function M.has_changes(buf)
    local st = state.get(buf)
    if st and st.needs_refresh then
        return false
    end
    local ops, err = plan.plan_ops(buf)
    return err ~= nil or (ops and #ops > 0) or false
end

---@param buf integer
function M.refresh_git_status(buf)
    local st = state.get(buf)
    if not st then
        return
    end
    local root = st.root
    st.git_generation = st.git_generation + 1
    local generation = st.git_generation
    git.fetch_status(root, function(status, files)
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        local current = state.get(buf)
        if current ~= st or current.root ~= root or current.git_generation ~= generation then
            return
        end
        state.set_git_status(buf, status, files)
        render.add_virtual_text(buf, root)
    end)
end

local function render_snapshot(buf, st)
    local lines, err = listing.build_lines(st.root, { show_hidden = st.show_hidden })
    if not lines then
        utils.err_notify("Cannot read directory: " .. tostring(err), "adev-files")
        return false
    end
    if st.refresh_modifiable ~= nil then
        vim.bo[buf].modifiable = st.refresh_modifiable
        st.refresh_modifiable = nil
    end
    st.needs_refresh = false
    state.clear_pending_ops(buf)
    state.set_git_status(buf, nil)
    local name = "adev-files://" .. st.root
    local existing = vim.fn.bufnr(name)
    if existing >= 0 and existing ~= buf and vim.api.nvim_buf_is_valid(existing) then
        name = name .. "#" .. buf
    end
    vim.api.nvim_buf_set_name(buf, name)
    window.set_title_from_state(buf, st.root)
    render.render(buf, st.root, { lines = lines })
    index.index_original(buf)
    index.reindex(buf)
    render.add_virtual_text(buf, st.root)
    M.refresh_git_status(buf)
    return true
end

---@param buf integer
---@param opts? { force?: boolean }
---@return boolean
function M.refresh(buf, opts)
    local st = state.get(buf)
    if not st or st.applying or st.confirming then
        return false
    end
    if not (opts and opts.force) and M.has_changes(buf) then
        render.add_virtual_text(buf, st.root)
        M.refresh_git_status(buf)
        utils.notify("Save or discard changes before refreshing", vim.log.levels.WARN, "adev-files")
        return false
    end
    return render_snapshot(buf, st)
end

---@param buf integer
---@param opts? { keep_clipboard?: boolean }
---@return boolean, string?
function M.discard_reset(buf, opts)
    local st = state.get(buf)
    if st and (st.applying or st.confirming) then
        return false, "changes are being applied or confirmed"
    end
    if not st then
        local root = resolve_root(buf)
        if not root then
            return false, "missing root for discard"
        end
        st = state.init(buf, root)
    end
    st.root = roots.normalize_root(st.root)
    if not render_snapshot(buf, st) then
        return false, "cannot read directory"
    end
    if not (opts and opts.keep_clipboard) then
        clipboard.clear()
    end
    render.add_virtual_text(buf, st.root)
    return true
end

---@param buf integer
---@return boolean
function M.toggle_hidden(buf)
    local st = state.get(buf)
    if not st or st.applying or st.confirming then
        return false
    end
    if M.has_changes(buf) then
        utils.notify(
            "Save or discard changes before toggling hidden files",
            vim.log.levels.WARN,
            "adev-files"
        )
        return false
    end
    st.show_hidden = not st.show_hidden
    if not render_snapshot(buf, st) then
        st.show_hidden = not st.show_hidden
        return false
    end
    return true
end

---@param buf integer
---@param root string
---@return boolean
function M.set_root(buf, root)
    local st = state.get(buf)
    if not st or st.applying or st.confirming or M.has_changes(buf) then
        return false
    end
    local previous_root = st.root
    st.root = roots.normalize_root(root)
    if not render_snapshot(buf, st) then
        st.root = previous_root
        return false
    end
    return true
end

return M
