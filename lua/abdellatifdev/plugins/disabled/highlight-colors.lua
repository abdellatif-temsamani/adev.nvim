return {
    'brenoprata10/nvim-highlight-colors',
    enabled= false,
    event = require("abdellatifdev.consts").events.file,
    lazy = true,
    opts = {
        render = 'virtual',
        virtual_symbol = '■',
        virtual_symbol_prefix = '',
        enable_named_colors = true,
        enable_tailwind = true,
    }
}

