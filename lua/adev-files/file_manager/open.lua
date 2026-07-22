local utils = require "adev-common.utils"

local git = require "adev-files.git"
local listing = require "adev-files.file_manager.listing"
local render = require "adev-files.file_manager.render"
local roots = require "adev-files.file_manager.roots"
local state = require "adev-files.state"
local win = require "adev-files.file_manager.window"

local M = {}

---@class AdevFilesOpenOpts
---@field mode? 'float'|'current'
---@field buf? integer

---@param buf integer
local function configure_buffer(buf)
    vim.bo[buf].buflisted = false
    vim.bo[buf].filetype = "adev_files"
    vim.bo[buf].buftype = "acwrite"
    vim.bo[buf].modifiable = true
    vim.bo[buf].swapfile = false
    vim.bo[buf].bufhidden = "wipe"
end

---@param buf integer
---@param root string
local function set_buffer_name(buf, root)
    local name = "adev-files://" .. root
    local existing = vim.fn.bufnr(name)
    if existing >= 0 and existing ~= buf and vim.api.nvim_buf_is_valid(existing) then
        name = name .. "#" .. buf
    end
    vim.api.nvim_buf_set_name(buf, name)
end

---@param root? string
---@param opts? AdevFilesOpenOpts
---@return integer
function M.open(root, opts)
    opts = opts or {}
    local prev_win = vim.api.nvim_get_current_win()
    local previous_buf = vim.fn.bufnr "#"
    root = root or utils.files.get_dirname()
    root = roots.normalize_root(root)
    local lines = listing.build_lines(root)
    local current_mode = opts.mode == "current"

    local buf
    if current_mode then
        buf = opts.buf or vim.api.nvim_get_current_buf()
        if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_get_current_buf() ~= buf then
            error "cannot replace an inactive directory buffer"
        end
        configure_buffer(buf)
    else
        buf = utils.buffers.create(lines, {
            scratch = false,
            listed = false,
            bo = {
                filetype = "adev_files",
                buftype = "acwrite",
                modifiable = true,
                swapfile = false,
                bufhidden = "wipe",
            },
        })
    end

    -- Render header + entries on first open
    render.render(buf, root)

    -- avoid E32 and make buffer identity stable
    set_buffer_name(buf, root)

    -- keep this lazy to avoid require cycles
    require("adev-files.events").register(buf, root, { disable_global_actions = current_mode })

    if not current_mode then
        -- Prefer a taller window to allow editing/adding many entries.
        local max_height = math.max(3, vim.o.lines - 2)
        local header_offset = 4 -- virtual separator, root, summary, and blank line
        local height = math.min(math.max(#lines + header_offset, 20), max_height)
        win.create_win(buf, height, 72, root)
    end

    local manager_win = vim.api.nvim_get_current_win()
    pcall(vim.api.nvim_buf_set_var, buf, "adev_files_prev_win", prev_win)
    pcall(vim.api.nvim_buf_set_var, buf, "adev_files_win", manager_win)
    pcall(vim.api.nvim_buf_set_var, buf, "adev_files_mode", current_mode and "current" or "float")
    if previous_buf >= 0 and previous_buf ~= buf and vim.api.nvim_buf_is_valid(previous_buf) then
        pcall(vim.api.nvim_buf_set_var, buf, "adev_files_prev_buf", previous_buf)
    end

    -- Try to position cursor on the file that was active before opening
    local target_row = 2
    local ok_prev, prev_buf = pcall(vim.api.nvim_win_get_buf, prev_win)
    if ok_prev and prev_buf and vim.api.nvim_buf_is_valid(prev_buf) then
        local buf_name = vim.api.nvim_buf_get_name(prev_buf)
        if buf_name ~= "" then
            local fname = vim.fn.fnamemodify(buf_name, ":t")
            if fname ~= "" then
                local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                for i, line in ipairs(buf_lines) do
                    local stripped = line:gsub("/$", "")
                    if stripped == fname then
                        target_row = i
                        break
                    end
                end
            end
        end
    end
    pcall(vim.api.nvim_win_set_cursor, 0, { target_row, 0 })
    if vim.api.nvim_win_is_valid(manager_win) then
        vim.api.nvim_win_call(manager_win, function()
            local saved_view = vim.fn.winsaveview()
            saved_view.topline = 1
            vim.fn.winrestview(saved_view)
        end)
    end

    git.fetch_status(root, function(status)
        if not vim.api.nvim_buf_is_valid(buf) then
            return
        end
        state.set_git_status(buf, status)
        render.add_virtual_text(buf, root)
    end)

    return buf
end

return M
