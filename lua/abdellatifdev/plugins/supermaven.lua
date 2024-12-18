return {
    "supermaven-inc/supermaven-nvim",
    event = require("abdellatifdev.consts").file_event,
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
