local events = require "adev-common.utils.events"

return {
    "nvimtools/none-ls.nvim",
    dependencies = {
        "jay-babu/mason-null-ls.nvim",
    },
    event = { events.buffer.new_file, events.buffer.read_pre, events.file.read_pre },
    config = function()
        require "adev.config.none-ls"()
    end,
}
