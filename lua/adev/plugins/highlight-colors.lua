local events = require "adev.utils.consts.events"

return {
    "brenoprata10/nvim-highlight-colors",
    event = { events.file.read_pre, },
    opts = {
        render = "virtual",
        virtual_symbol = "■",
        virtual_symbol_prefix = "",
        enable_named_colors = true,
        enable_tailwind = true,
    }
}
