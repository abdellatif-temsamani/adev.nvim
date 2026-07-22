local files = require "adev-common.utils.files"
local configs = Adev.core_plugins
local adev_files = require "adev-files"

return {
    dir = files.adev_path .. "/lua/adev-files/",
    -- Directory buffers must be intercepted during startup, before netrw.
    lazy = not configs.adev_files.replace_netrw,
    config = function(_, opts)
        require("adev-files").setup(opts)
    end,
    opts = configs.adev_files,
    keys = {
        {
            "<leader>no",
            adev_files.open,
            desc = "open file manager",
        },
        {
            "<leader>na",
            adev_files.create_file,
            desc = "create",
        },
        {
            "<leader>nr",
            adev_files.rename_file,
            desc = "rename",
        },
        {
            "<leader>nd",
            adev_files.delete_file,
            desc = "delete",
        },
    },
}
