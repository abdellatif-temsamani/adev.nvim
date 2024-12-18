return {
    'stevearc/oil.nvim',
    keys = {
        { "<leader>n", "<cmd>Oil<cr>", desc = "Open Oil" },
    },
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
}
