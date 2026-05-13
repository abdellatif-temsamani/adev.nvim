local plugin = require "adev-common.plugin"

return {
    "numToStr/Comment.nvim",
    event = plugin.file_events(),
    opts = {},
}
