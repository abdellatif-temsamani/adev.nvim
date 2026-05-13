local plugin = require "adev-common.plugin"

return {
    "pwntester/octo.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    keys = {
        { "<leader>tc", "<CMD>Octo<CR>", desc = "Octo commands", mode = "n" },
    },
    cond = plugin.is_git_worktree,
    opts = {
        enable_builtin = true,
    },
}
