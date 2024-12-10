return {
    'nvimtools/none-ls.nvim',
    event = require("abdellatifdev.consts").file_event,
    config = function() require('abdellatifdev.none-ls').setup() end
}
