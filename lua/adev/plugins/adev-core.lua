local files = require "adev-common.utils.files"
local configs = Adev.core_plugins
local adev_files = require "adev-files"

return {
    dir = files.adev_path .. "/lua/adev-files/",
    config = function(_, opts)
        require("adev-files").setup(opts)
    end,
    opts = configs.adev_files,
    cond = Adev.flags.experimental_adev_files,
    keys = {
        {
            "<leader>no",
            adev_files.open,
            desc = "open file manager",
        },
        {
            "<leader>na",
            adev_files.create_file,
            desc = "create file",
        },
        {
            "<leader>nr",
            adev_files.rename_file,
            desc = "rename file",
        },
        {
            "<leader>nd",
            adev_files.delete_file,
            desc = "delete file",
        },
    },
}
