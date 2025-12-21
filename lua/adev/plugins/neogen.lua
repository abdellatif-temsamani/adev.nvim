local events = require "adev.utils.events"

-- NOTE: may remove later,
-- if you wish you to keep the plugin copy this file to ../custom-plugins/
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
