return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = true,
            integrations = {
                noice = true,
                gitsigns = true,
                snacks = {
                    enabled = true,
                },
                telescope = {
                    enabled = true,
                },
            },
        })

        vim.cmd("colorscheme catppuccin")
    end
}
