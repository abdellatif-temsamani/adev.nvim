local events = require "adev.utils.consts.events"

return {
    "augmentcode/augment.vim",
    event = { events.file.read_pre, events.insert.enter },
}
