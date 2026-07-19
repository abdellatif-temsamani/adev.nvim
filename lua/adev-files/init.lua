local file_manager = require "adev-files.file_manager"
local select = require "adev-common.ui.select"
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
    vim.ui.input({ prompt = "New file path (relative to cwd): " }, function(input)
        if not input or input == "" then
            return
        end
        local path = vim.fn.fnamemodify(input, ":p")
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
        local ok, err = vim.loop.fs_rename(file, new_path)
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
    select(
        "Delete '" .. name .. "'?",
        { "Yes", "No" },
        function(item, idx)
            if idx ~= 1 then
                return
            end
            local ok, err = vim.loop.fs_unlink(file)
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
