local events = require "adev.utils.consts.events"

return {
    "numToStr/Comment.nvim",
    event = { events.buffer.new_file },
    opts = {},
}
