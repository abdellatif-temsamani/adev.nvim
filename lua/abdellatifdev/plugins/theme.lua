return {
    {
        "folke/tokyonight.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            ---@diagnostic disable-next-line: missing-fields
            require("tokyonight").setup({
                style = "night",
                transparent = true,
                terminal_colors = true,
                dim_inactive = true,
                lualine_bold = true
            })
            vim.cmd([[colorscheme tokyonight]])
        end,
    },

    -- {
    --     'uZer/pywal16.nvim',
    --     config = function()
    --         vim.cmd([[colorscheme pywal16]])
    --     end,
    -- }

}
