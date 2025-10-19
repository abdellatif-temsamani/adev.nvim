local events = require "adev.utils.consts.events"

return {
    {
        "augmentcode/augment.vim",
        enabled = false,
        event = { events.file.read_pre, events.insert.enter },
    },
    {
        "supermaven-inc/supermaven-nvim",
        event = { events.insert.enter },
        opts = {},
    },
}
