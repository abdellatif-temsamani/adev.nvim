local plugin = require "adev-common.plugin"

return {
    "brenoprata10/nvim-highlight-colors",
    event = plugin.file_events(),
    opts = {
        render = "virtual",
        virtual_symbol = "■",
        virtual_symbol_prefix = "",
        enable_named_colors = true,
        enable_tailwind = true,
    },
}
