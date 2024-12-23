return {
    'nvimtools/none-ls.nvim',
    event = require("abdellatifdev.consts").events.file,
    config = function() require('abdellatifdev.none-ls').setup() end
}
