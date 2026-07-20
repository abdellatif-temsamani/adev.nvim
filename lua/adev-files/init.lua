local file_manager = require "adev-files.file_manager"
local select = require "adev-common.ui.select"
local fs_ops = require "adev-files.sync.fs_ops"
local M = {}

---@class FilesProps
---@class FilesOpenFilesProps
---@field enabled boolean
---@field method 'edit'|'split'|'vsplit'|'tabedit'

---@type FilesProps
M.defaults = {
    open_files = {
        enabled = false,
        method = "edit",
    },
}

---@type FilesProps
M.config = vim.deepcopy(M.defaults)

---@param opts? FilesProps
function M.setup(opts)
    ---@type FilesProps
    opts = vim.tbl_deep_extend("force", {}, M.defaults, opts or {})
    M.config = opts
end

---@return FilesProps
function M.get_config()
    return M.config or M.defaults
end

function M.open()
    local ok, err = pcall(file_manager.open)
    if not ok then
        vim.notify("adev-files: " .. tostring(err), vim.log.levels.ERROR)
    end
end

function M.create_file()
    vim.ui.input({ prompt = "New path (relative to cwd, append / for directory): " }, function(input)
        if not input or input == "" then
            return
        end
        local is_dir = input:sub(-1) == "/"
        local path = vim.fn.fnamemodify(input, ":p")
        if is_dir then
            local ok, err = fs_ops.mkdir_p(path)
            if ok then
                vim.notify("Created directory: " .. input, vim.log.levels.INFO, "adev-files")
            else
                vim.notify("Failed to create directory: " .. tostring(err), vim.log.levels.ERROR, "adev-files")
            end
            return
        end
        local dir = vim.fn.fnamemodify(path, ":h")
        if vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
        end
        if vim.fn.filereadable(path) == 0 then
            local fd = vim.loop.fs_open(path, "w", 420)
            if fd then
                vim.loop.fs_close(fd)
            end
        end
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        vim.notify("Created: " .. input, vim.log.levels.INFO, "adev-files")
    end)
end

function M.rename_file()
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" then
        vim.notify("No file in current buffer", vim.log.levels.WARN, "adev-files")
        return
    end
    local old_name = vim.fn.fnamemodify(file, ":t")
    vim.ui.input({ prompt = "Rename to: ", default = old_name }, function(input)
        if not input or input == "" or input == old_name then
            return
        end
        local dir = vim.fn.fnamemodify(file, ":h")
        local new_path = dir .. "/" .. input
        local ok, err = fs_ops.rename_path(file, new_path)
        if ok then
            vim.api.nvim_buf_set_name(buf, new_path)
            vim.notify("Renamed: " .. old_name .. " -> " .. input, vim.log.levels.INFO, "adev-files")
        else
            vim.notify("Rename failed: " .. tostring(err), vim.log.levels.ERROR, "adev-files")
        end
    end)
end

function M.delete_file()
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" then
        vim.notify("No file in current buffer", vim.log.levels.WARN, "adev-files")
        return
    end
    local name = vim.fn.fnamemodify(file, ":t")
    local is_dir = vim.fn.isdirectory(file) == 1
    local prompt = is_dir and ("Delete directory '" .. name .. "'?") or ("Delete '" .. name .. "'?")
    select(
        prompt,
        { "Yes", "No" },
        function(item, idx)
            if idx ~= 1 then
                return
            end
            local ok, err
            if is_dir then
                ok, err = fs_ops.rm_rf(file)
            else
                ok, err = vim.loop.fs_unlink(file)
            end
            if ok then
                vim.cmd("bwipeout! " .. buf)
                vim.notify("Deleted: " .. name, vim.log.levels.INFO, "adev-files")
            else
                vim.notify("Delete failed: " .. tostring(err), vim.log.levels.ERROR, "adev-files")
            end
        end
    )
end

return M
