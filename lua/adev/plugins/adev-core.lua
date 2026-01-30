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
            "<leader>n",
            require("adev-files").open,
            desc = "list files in cwd",
        },
    },
}
