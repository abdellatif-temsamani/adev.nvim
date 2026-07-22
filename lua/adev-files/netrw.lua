local file_manager = require "adev-files.file_manager"

local M = {}

local GROUP = "adev_files_netrw"
local opening = {}

---@param buf integer
local function open_directory_buffer(buf)
    if opening[buf] or not vim.api.nvim_buf_is_valid(buf) then
        return
    end
    if vim.api.nvim_get_current_buf() ~= buf or vim.bo[buf].buftype ~= "" then
        return
    end

    local directory = vim.api.nvim_buf_get_name(buf)
    if directory == "" or vim.fn.isdirectory(directory) ~= 1 then
        return
    end

    opening[buf] = true
    local ok, err = pcall(file_manager.open, directory, { mode = "current", buf = buf })
    opening[buf] = nil
    if not ok then
        vim.notify("adev-files: " .. tostring(err), vim.log.levels.ERROR)
    end
end

function M.setup()
    -- Prevent the built-in plugin from registering its FileExplorer autocmd.
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    pcall(vim.api.nvim_del_augroup_by_name, "FileExplorer")

    local group = vim.api.nvim_create_augroup(GROUP, { clear = true })
    vim.api.nvim_create_autocmd("BufEnter", {
        group = group,
        callback = function(args)
            open_directory_buffer(args.buf)
        end,
        desc = "Open directory buffers with adev-files",
    })
    vim.api.nvim_create_autocmd("VimEnter", {
        group = group,
        once = true,
        callback = function()
            open_directory_buffer(vim.api.nvim_get_current_buf())
        end,
        desc = "Replace netrw startup directory with adev-files",
    })
end

function M.teardown()
    pcall(vim.api.nvim_del_augroup_by_name, GROUP)
end

return M
