local ui = require "adev-common.ui"
local utils = require "adev-common.utils"

---@param input? string
---@return nil
local function on_create(input)
    if not input or input == "" then
        utils.notify("No file/dir to create", vim.log.levels.ERROR)
        return
    end

    if utils.files.file_exists(input) then
        utils.notify("path already exists", vim.log.levels.ERROR)
        return
    end

    -- Normalize input: remove trailing slashes for uniformity
    local path = input:gsub("/+$", "")

    -- Determine if the user wants a directory
    local is_dir = vim.fn.isdirectory(path) == 1 or input:sub(-1) == "/"

    if is_dir then
        -- Create directory and all intermediate dirs
        local ok = vim.fn.mkdir(path, "p")
        if ok == 1 then
            utils.notify("Directory created: " .. path)
        else
            utils.notify("Error creating directory: " .. path, vim.log.levels.ERROR)
        end
        return
    end

    -- Ensure parent directories exist for files
    local dir = vim.fn.fnamemodify(path, ":h")
    if dir ~= "" then
        local ok = vim.fn.mkdir(dir, "p")
        if ok ~= 1 then
            utils.notify("Error creating parent directories: " .. dir, vim.log.levels.ERROR)
            return
        end
    end

    -- Create the file
    local file = io.open(path, "w")
    if file then
        file:write ""
        file:close()
        utils.notify("File created: " .. path)
        vim.cmd("e " .. vim.fn.fnameescape(path))
    else
        utils.notify("Error creating file: " .. path, vim.log.levels.ERROR)
    end
end

return function()
    local dir = utils.files.get_dirname() or ""
    ui.input("Create a file/dir [trailing / for dir]", on_create, {
        default = dir,
        completion = "file",
        title = "adev-files",
    })
end
