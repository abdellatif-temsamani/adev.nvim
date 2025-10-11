local events = require "adev.utils.consts.events"

return {
    "numToStr/Comment.nvim",
    event = { events.file.read_pre},
    opts = {}
}
