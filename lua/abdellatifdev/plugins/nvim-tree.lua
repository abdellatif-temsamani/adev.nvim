return {
    'nvim-tree/nvim-tree.lua',
    keys = {
        { "<leader>n", "<cmd>NvimTreeToggle<cr>", desc = "Open Oil" },
    },
    opts = {
        view_options={
            show_hidden=true,
        }
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if prefer nvim-web-devicons
}
