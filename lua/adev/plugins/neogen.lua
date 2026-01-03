local events = require "adev.utils.events"

return {
    "danymat/neogen",
    event = { events.buffer.new_file, events.buffer.read_pre, events.file.read_pre },
    keys = {
        {
            "<leader>gu",
            function()
                require("neogen").generate()
            end,
            desc = "Neogen",
        },
    },
    opts = {},
}
