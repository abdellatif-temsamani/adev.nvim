return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    keys = {
        { "<leader>n", "<cmd>Neotree toggle<cr>", desc = "Open Tree" },
    },
    opts = {
        close_if_last_window = true,
        window = {
            position = "left",
            width = 30,
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        "3rd/image.nvim",
    }
}
