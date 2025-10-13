local events = require "adev.utils.consts.events"

return {
    "augmentcode/augment.vim",
    event = { events.buffer.file_pre, events.insert.enter },
}
