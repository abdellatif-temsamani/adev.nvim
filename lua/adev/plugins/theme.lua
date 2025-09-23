return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
        flavour = "mocha",
        transparent_background = false,
        dim_inactive = {
            enabled = true,
            shade = "dark",
            percentage = 0.15,
        },
        auto_integrations = true,
        default_integrations = true,
        integrations = {
            blink_cmp = {
                style = 'single',
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
    }
}
