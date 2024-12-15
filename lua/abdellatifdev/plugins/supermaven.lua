return {
    "supermaven-inc/supermaven-nvim",
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
