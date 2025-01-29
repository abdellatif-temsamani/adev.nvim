return {
    'declancm/maximize.nvim',
    event = require("abdellatifdev.consts").events.file,
    keys = {
        { "<leader>wa", function() require('maximize').toggle() end, desc = "maximize window" },
    },
    opts = {},
}

