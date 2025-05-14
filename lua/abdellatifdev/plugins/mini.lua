return {
    'echasnovski/mini.nvim',
    version = '*',
    priority = 1000,
    lazy = false,
    config = function()
        require("abdellatifdev.mini-config")
    end,
    keys = {
        { "<leader>n", function() MiniFiles.open(vim.fn.expand('%:p:h')) end, desc = "Mini Files" },
    },
}
