local events = require("adev.utils.consts.events")

return {
    'numToStr/Comment.nvim',
    event = { events.buffer.read_pre, events.buffer.new },
    opts = {}
}
