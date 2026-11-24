local M = {}

local NS, LIVE_NS, DISPLAY_NS

local function ensure_namespaces()
    NS = NS or vim.api.nvim_create_namespace "adev-files"
    LIVE_NS = LIVE_NS or vim.api.nvim_create_namespace "adev_files_live"
    DISPLAY_NS = DISPLAY_NS or vim.api.nvim_create_namespace "adev_files_display"
end

local model = require "adev-files.core.model"

---@class AdevFilesState
---@field root string
---@field initial_root string
---@field model AdevFilesModel
---@field view AdevFilesProjection|nil
---@field applying boolean
---@field confirming boolean
---@field pending_ops AdevFilesOp[]
---@field original_lines table<integer, {entry: AdevFilesEntry, abs_path: string}>
---@field show_hidden boolean
---@field selection_marks table<integer, true>
---@field selection_ids table<integer, true>
---@field missing_ids table<integer, integer>
---@field update_scheduled boolean
---@field git_status table<string, string>|nil  -- rel_path -> status char (includes directory aggregates)
---@field git_files table<string, string>|nil -- direct file statuses only
---@field git_generation integer
---@field git_available boolean|nil
---@field git_reason? string
---@field row_changes table<integer, AdevFilesRowChange>
---@field plan_error string|nil
---@field plan_error_rows integer[]
---@field needs_refresh boolean
---@field refresh_modifiable? boolean

---@type table<integer, AdevFilesState>
local states = {}

function M.ns()
    ensure_namespaces()
    return NS
end

function M.display_ns()
    ensure_namespaces()
    return DISPLAY_NS
end

function M.live_ns()
    ensure_namespaces()
    return LIVE_NS
end

---@param buf integer
---@param root string
---@return AdevFilesState
function M.init(buf, root)
    local previous = states[buf]
    states[buf] = {
        root = root,
        -- The first root stays the anchor for "back to start" navigation.
        initial_root = previous and previous.initial_root or root,
        model = model.new(root),
        view = nil,
        applying = false,
        confirming = false,
        pending_ops = {},
        original_lines = {},
        show_hidden = false,
        selection_marks = {},
        selection_ids = {},
        missing_ids = {},
        update_scheduled = false,
        git_status = nil,
        git_files = nil,
        git_generation = (previous and previous.git_generation or 0) + 1,
        git_available = nil,
        git_reason = nil,
        row_changes = {},
        plan_error = nil,
        plan_error_rows = {},
        needs_refresh = false,
        refresh_modifiable = nil,
    }

    -- Any state creation gets a teardown hook, including paths that bypass
    -- sync/attach (for example discard-reset of a plain buffer).
    local group = vim.api.nvim_create_augroup("adev_files_state_" .. buf, { clear = true })
    vim.api.nvim_create_autocmd("BufWipeout", {
        group = group,
        buffer = buf,
        callback = function(args)
            M.clear(args.buf)
        end,
    })

    return states[buf]
end

---@param buf integer
---@return AdevFilesState|nil
function M.get(buf)
    return states[buf]
end

---@param buf integer
---@param next_model AdevFilesModel
function M.set_model(buf, next_model)
    if not states[buf] then
        return
    end
    states[buf].model = next_model
end

---@param buf integer
---@return AdevFilesModel|nil
function M.get_model(buf)
    local st = states[buf]
    if not st then
        return nil
    end
    return st.model
end

---@param buf integer
---@param view AdevFilesProjection|nil
function M.set_view(buf, view)
    if not states[buf] then
        return
    end
    states[buf].view = view
end

---@param buf integer
---@return AdevFilesProjection|nil
function M.get_view(buf)
    local st = states[buf]
    if not st then
        return nil
    end
    return st.view
end

---@param buf integer
---@return AdevFilesOp[]
function M.get_pending_ops(buf)
    local st = states[buf]
    if not st then
        return {}
    end
    return st.pending_ops or {}
end

---@param buf integer
---@param ops AdevFilesOp[]
function M.set_pending_ops(buf, ops)
    if not states[buf] then
        return
    end
    states[buf].pending_ops = ops or {}
end

---@param buf integer
function M.clear_pending_ops(buf)
    if not states[buf] then
        return
    end
    states[buf].pending_ops = {}
end

---@param buf integer
---@param lines table<integer, {entry: AdevFilesEntry, abs_path: string}>
function M.set_original_lines(buf, lines)
    if not states[buf] then
        return
    end
    states[buf].original_lines = lines or {}
end

---@param buf integer
---@return table<integer, {entry: AdevFilesEntry, abs_path: string}>
function M.get_original_lines(buf)
    local st = states[buf]
    if not st then
        return {}
    end
    return st.original_lines or {}
end

---@param buf integer
---@return boolean
function M.get_show_hidden(buf)
    local st = states[buf]
    if not st then
        return false
    end
    return st.show_hidden or false
end

---@param buf integer
---@param val boolean
function M.set_show_hidden(buf, val)
    if not states[buf] then
        return
    end
    states[buf].show_hidden = val
end

---@param buf integer
---@return table<integer, true>
function M.get_selection_marks(buf)
    local st = states[buf]
    local rows = {}
    if st and vim.api.nvim_buf_is_valid(buf) then
        local parse = require "adev-files.parse"
        for i, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
            local _, id = parse.strip_id(line)
            if id and st.selection_ids[id] then
                rows[i - 1] = true
            end
        end
    end
    return rows
end

---@param buf integer
---@param marks table<integer, true>
function M.set_selection_marks(buf, marks)
    if not states[buf] then
        return
    end
    states[buf].selection_marks = marks or {}
    states[buf].selection_ids = {}
    local parse = require "adev-files.parse"
    local line_count = vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_line_count(buf) or 0
    for row in pairs(marks or {}) do
        if row >= 0 and row < line_count then
            local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
            local _, id = parse.strip_id(line)
            if id then
                states[buf].selection_ids[id] = true
            end
        end
    end
end

---@param buf integer
function M.clear_selection_marks(buf)
    if not states[buf] then
        return
    end
    states[buf].selection_marks = {}
    states[buf].selection_ids = {}
end

---@param buf integer
---@return table<string, string>|nil
function M.get_git_status(buf)
    local st = states[buf]
    if not st then
        return nil
    end
    return st.git_status
end

---@param buf integer
---@param status table<string, string>|nil
---@param files? table<string, string>|nil
---@param meta? AdevFilesGitMeta
function M.set_git_status(buf, status, files, meta)
    if not states[buf] then
        return
    end
    states[buf].git_status = status
    states[buf].git_files = files
    if meta then
        states[buf].git_available = meta.available
        states[buf].git_reason = meta.reason
    end
end

---@param buf integer
function M.clear(buf)
    states[buf] = nil
end

return M
