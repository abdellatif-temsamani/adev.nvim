return {
    'echasnovski/mini.nvim',
    version = '*',
    keys = {
        { "<leader>bq", function() require('mini.bufremove').wipeout() end, desc = "close buffer", },
    },
    priority = 1000,
    lazy = false,
    config = function()
        require("adev.config.mini")
    end,
}
