local M = {
    adev_path = vim.fn.stdpath "config",
}

--- Checks if a file exists
---@param path string
---@return boolean
function M.file_exists(path)
    return vim.fn.filereadable(path) == 1
end

--- Open or create a file then write the content to it
---@param path string
---@param content string[]
---@param mode? openmode
function M.write_file(path, content, mode)
    ---@type openmode
    mode = mode or "w"

    local file = assert(io.open(path, mode), "Failed to open " .. path)
    file:write(table.concat(content))
    file:close()
end

--- get a file in adev config
---@param relative_path string erample `"/init.lua"`
---@return string
function M:get_config_file(relative_path)
    return self.adev_path .. relative_path
end

return M
