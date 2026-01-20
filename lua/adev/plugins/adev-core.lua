local files = require "adev-common.utils.files"

return {
    dir = files.adev_path .. "/lua/adev-files/",
    config = function(_, opts)
        require("adev-files").setup(opts)
    end,
    opts = {},
    cond = Adev.flags.experimental_adev_files,
    keys = {
        {
            "<leader>nl",
            require("adev-files.actions").list,
            desc = "list files in cwd",
        },
        {
            "<leader>na",
            require("adev-files.actions").create,
            desc = "create a file/dir",
        },
    },
}
