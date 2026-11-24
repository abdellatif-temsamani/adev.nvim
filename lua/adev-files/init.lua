local select = require "adev-common.ui.select"

local clipboard = require "adev-files.clipboard"
local file_manager = require "adev-files.file_manager"
local fs_ops = require "adev-files.sync.fs_ops"
local path = require "adev-files.utils.fs.path"
local uv = vim.uv or vim.loop

local M = {}

---@class FilesProps
---@field replace_netrw boolean
---@field open_files FilesOpenFilesProps
---@class FilesOpenFilesProps
---@field enabled boolean
---@field method 'edit'|'split'|'vsplit'|'tabedit'

---@type FilesProps
M.defaults = {
    replace_netrw = true,
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

    vim.api.nvim_create_user_command("AdevFiles", function(args)
        local path = args.args ~= "" and vim.fn.fnamemodify(args.args, ":p") or vim.fn.getcwd()
        if vim.fn.isdirectory(path) == 0 then
            path = vim.fn.fnamemodify(path, ":h")
        end
        M.open(path)
    end, {
        nargs = "?",
        complete = "file",
        desc = "Open adev-files file manager",
    })

    local netrw = require "adev-files.netrw"
    if opts.replace_netrw then
        netrw.setup()
    else
        netrw.teardown()
    end
end

---@return FilesProps
function M.get_config()
    return M.config or M.defaults
end

---@param root? string
function M.open(root)
    local ok, err = pcall(file_manager.open, root)
    if not ok then
        vim.notify("adev-files: " .. tostring(err), vim.log.levels.ERROR)
    end
end

function M.create_file()
    local st = require("adev-files.state").get(vim.api.nvim_get_current_buf())
    local base = st and st.root or vim.fn.getcwd()
    local prompt = st and "New path (relative to file manager root, append / for directory): "
        or "New path (relative to cwd, append / for directory): "
    vim.ui.input({ prompt = prompt }, function(input)
        if not input or input == "" then
            return
        end
        local is_dir = input:sub(-1) == "/"
        local rel = is_dir and input:sub(1, -2) or input
        local validation = require "adev-files.validation"
        local ok_rel, rel_err = validation.validate_rel_dir(rel)
        if not ok_rel or rel_err ~= rel:gsub("^%s+", ""):gsub("%s+$", "") then
            vim.notify(
                "Invalid path: " .. tostring(rel_err or "invalid path"),
                vim.log.levels.ERROR,
                { title = "adev-files" }
            )
            return
        end
        local clean_rel = rel_err
        local abs_path = require("adev-files.utils.fs.path").join_abs(base, clean_rel)
        if is_dir then
            local ok, err = fs_ops.mkdir_p(abs_path)
            if ok then
                vim.notify(
                    "Created directory: " .. input,
                    vim.log.levels.INFO,
                    { title = "adev-files" }
                )
            else
                vim.notify(
                    "Failed to create directory: " .. tostring(err),
                    vim.log.levels.ERROR,
                    { title = "adev-files" }
                )
            end
            return
        end
        local dir = vim.fn.fnamemodify(abs_path, ":h")
        local ok_mkdir, mkdir_err = fs_ops.mkdir_p(dir)
        if not ok_mkdir then
            vim.notify(
                "Failed to create directory: " .. tostring(mkdir_err),
                vim.log.levels.ERROR,
                { title = "adev-files" }
            )
            return
        end

        local existed = vim.fn.filereadable(abs_path) == 1 or vim.fn.isdirectory(abs_path) == 1
        if not existed then
            local fd, ferr_name, ferr_msg = uv.fs_open(abs_path, "wx", 420)
            if not fd then
                vim.notify(
                    "Failed to create file: "
                        .. abs_path
                        .. " - "
                        .. tostring(ferr_name or ferr_msg),
                    vim.log.levels.ERROR,
                    { title = "adev-files" }
                )
                return
            end
            local ok_close, close_err = uv.fs_close(fd)
            if not ok_close then
                vim.notify(
                    "Failed to close new file: " .. abs_path .. " - " .. tostring(close_err),
                    vim.log.levels.ERROR,
                    { title = "adev-files" }
                )
                return
            end
        end

        local ok_edit, edit_err = pcall(function()
            vim.cmd("edit " .. vim.fn.fnameescape(abs_path))
        end)
        if not ok_edit then
            vim.notify(
                "Failed to open " .. abs_path .. ": " .. tostring(edit_err),
                vim.log.levels.ERROR,
                { title = "adev-files" }
            )
            return
        end
        vim.notify(
            (existed and "Opened: " or "Created: ") .. input,
            vim.log.levels.INFO,
            { title = "adev-files" }
        )
    end)
end

function M.rename_file()
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" then
        vim.notify("No file in current buffer", vim.log.levels.WARN, { title = "adev-files" })
        return
    end
    local old_name = vim.fn.fnamemodify(file, ":t")
    local st = require("adev-files.state").get(buf)
    local prompt = st and "Rename to (name only): " or "Rename to: "
    vim.ui.input({ prompt = prompt, default = old_name }, function(input)
        if not input or input == "" or input == old_name then
            return
        end
        local validation = require "adev-files.validation"
        local clean = input:gsub("^%s+", ""):gsub("%s+$", "")
        if clean == "" or clean:find("/", 1, true) or clean == "." or clean == ".." then
            vim.notify(
                "Invalid name: use a single name without path separators",
                vim.log.levels.ERROR,
                { title = "adev-files" }
            )
            return
        end
        if not validation.is_valid_rel_path(clean) then
            vim.notify("Invalid name: " .. input, vim.log.levels.ERROR, { title = "adev-files" })
            return
        end
        local dir = vim.fn.fnamemodify(file, ":h")
        local new_path = path.join_abs(dir, clean)
        local ok, err = fs_ops.rename_path(file, new_path)
        if not ok then
            vim.notify(
                "Rename failed: " .. tostring(err),
                vim.log.levels.ERROR,
                { title = "adev-files" }
            )
            return
        end

        -- The filesystem move is committed first; if the buffer cannot follow
        -- it, move the file back so the name on disk and the name in the editor
        -- never disagree.
        local buffer_ok, buffer_err = pcall(vim.api.nvim_buf_set_name, buf, new_path)
        if buffer_ok then
            -- Renaming a buffer makes Neovim treat the destination as a new
            -- file. Since the filesystem move already created it, the next
            -- regular :write would otherwise ask whether to overwrite it.
            -- Writing once with ! also preserves any edits made before the
            -- rename and refreshes Neovim's file metadata for later writes.
            buffer_ok, buffer_err = pcall(vim.api.nvim_buf_call, buf, function()
                vim.cmd "silent write!"
            end)
        end

        if not buffer_ok then
            local rollback_ok, rollback_err = fs_ops.rename_path(new_path, file)
            if rollback_ok then
                pcall(vim.api.nvim_buf_set_name, buf, file)
            end
            vim.notify(
                rollback_ok and ("Rename failed: " .. tostring(buffer_err))
                    or (
                        "Renamed on disk to "
                        .. new_path
                        .. ", but the buffer could not follow: "
                        .. tostring(buffer_err)
                        .. "; rollback failed: "
                        .. tostring(rollback_err)
                    ),
                vim.log.levels.ERROR,
                { title = "adev-files" }
            )
            return
        end

        vim.notify(
            "Renamed: " .. old_name .. " -> " .. clean,
            vim.log.levels.INFO,
            { title = "adev-files" }
        )
    end)
end

function M.delete_file()
    local buf = vim.api.nvim_get_current_buf()
    local file = vim.api.nvim_buf_get_name(buf)
    if file == "" then
        vim.notify("No file in current buffer", vim.log.levels.WARN, { title = "adev-files" })
        return
    end
    local name = vim.fn.fnamemodify(file, ":t")
    local is_dir = vim.fn.isdirectory(file) == 1
    local prompt = is_dir and ("Delete directory '" .. name .. "'?") or ("Delete '" .. name .. "'?")
    select(prompt, { "Yes", "No" }, function(item, idx)
        if idx ~= 1 then
            return
        end
        local ok, err
        if is_dir then
            ok, err = fs_ops.rm_rf(file)
        else
            local pcall_ok, unlink_ok, unlink_err = pcall(uv.fs_unlink, file)
            ok, err = pcall_ok and unlink_ok == true, unlink_err
        end
        if ok then
            clipboard.remove_by_src(file)
            if vim.api.nvim_buf_is_valid(buf) then
                pcall(function()
                    vim.cmd("bwipeout! " .. buf)
                end)
            end
            vim.notify("Deleted: " .. name, vim.log.levels.INFO, { title = "adev-files" })
        else
            vim.notify(
                "Delete failed: " .. tostring(err),
                vim.log.levels.ERROR,
                { title = "adev-files" }
            )
        end
    end)
end

return M
