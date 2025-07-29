return {
    'echasnovski/mini.nvim',
    version = '*',
    priority = 1000,
    lazy = false,
    config = function()
        require("abdellatifdev.mini-config")
    end,
}
