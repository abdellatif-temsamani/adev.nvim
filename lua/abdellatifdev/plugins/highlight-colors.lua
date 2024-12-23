return {
    'brenoprata10/nvim-highlight-colors',
    event = require("abdellatifdev.consts").events.file,
    lazy = true,
    opts = {
        render = 'virtual',
        ---Set virtual symbol (requires render to be set to 'virtual')
        virtual_symbol = '■',

        ---Set virtual symbol suffix (defaults to '')
        virtual_symbol_prefix = '',
        enable_named_colors = true,
        enable_tailwind = true,
    }
}

