return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = false,
            dim_inactive = {
                enabled = true,    -- dims the background color of inactive window
                shade = "dark",
                percentage = 0.15, -- percentage of the shade to apply to the inactive window
            },
            auto_integrations = true,
            integrations = {
                blink_cmp = {
                    style = 'bordered',
                },
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

        vim.cmd.colorscheme "catppuccin"
    end
}
