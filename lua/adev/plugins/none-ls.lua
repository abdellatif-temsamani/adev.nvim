return {
    'nvimtools/none-ls.nvim',
    event = require("adev.consts").events.file,
    config = function() require('adev.config.none-ls').setup() end
}
