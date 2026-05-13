local plugin = require "adev-common.plugin"

return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "jay-babu/mason-null-ls.nvim",
    },
    event = plugin.file_events(),
    config = function()
        require "adev.config.none-ls"()
    end,
}
