local ui = require "adev-common.ui"
local utils = require "adev-common.utils"

return function()
    local pwd = utils.files.get_dirname()
    local files = vim.fs.dir(pwd)

    local current_files = {}
    for name, type in files do
        table.insert(current_files, string.format("%s: %s", type, name))
    end
    table.sort(
        current_files,
        ---@param a string
        ---@param b string
        function(a, b)
            local a_is_dir = a:sub(1, 10) == "directory:"
            local b_is_dir = b:sub(1, 10) == "directory:"

            -- directories first
            if a_is_dir ~= b_is_dir then
                return a_is_dir
            end

            -- same type → compare names (trim prefix)
            local a_name = a:gsub("^(directory|file):%s*", "")
            local b_name = b:gsub("^(directory|file):%s*", "")

            return a_name < b_name
        end
    )
    local buf = ui.window.create_buf(current_files, true, true)

    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "adev_files"

    vim.keymap.set({ "n", "v" }, "q", "<cmd>bwipeout<CR>", { buffer = buf })
    vim.cmd "vsplit"
    vim.api.nvim_set_current_buf(buf)
end
