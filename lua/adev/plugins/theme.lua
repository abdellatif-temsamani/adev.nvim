return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    enabled = Adev.catppuccin.enable,
    opts = {
        flavour = Adev.catppuccin.flavour,
        transparent_background = Adev.catppuccin.transparent,
        dim_inactive = {
            enabled = true,
            shade = "dark",
            percentage = 0.1,
        },
        auto_integrations = true,
        default_integrations = true,
        integrations = {
            mini = {
                enabled = true,
                indentscope_color = "blue",
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
    },
}
