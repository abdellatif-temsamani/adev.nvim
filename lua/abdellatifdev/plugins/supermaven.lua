return {
    "supermaven-inc/supermaven-nvim",
    enabled = true,
    event = require("abdellatifdev.consts").events.file,
    config = function()
        require("supermaven-nvim").setup({
            keymaps = {
                -- alt-l
                accept_suggestion = "<M-l>",
                clear_suggestion = "<C-]>",
                accept_word = "<C-j>",
            },
        })
    end,
}
