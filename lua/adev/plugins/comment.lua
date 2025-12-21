local events = require "adev.utils.events"

return {
    "numToStr/Comment.nvim",
    event = { events.buffer.new_file, events.buffer.read_pre, events.file.read_pre },
    opts = {},
}
