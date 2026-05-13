local plugin = require "adev-common.plugin"

return {
    "danymat/neogen",
    event = plugin.file_events(),
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
