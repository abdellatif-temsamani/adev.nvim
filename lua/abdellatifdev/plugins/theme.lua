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
                    picker_style = "nvchad_outlined",
                },
                telescope = {
                    enabled = true,
                    style = "nvchad_outlined",
                },
            },
        })

        vim.cmd("colorscheme catppuccin")
    end
}
