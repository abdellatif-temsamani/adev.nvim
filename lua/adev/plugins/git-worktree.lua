return {
    'Juksuu/worktrees.nvim',
    cond = function()
        return vim.fn.system("git rev-parse --is-bare-repository 2>/dev/null"):gsub("\n", "") == "true"
    end,
    dependencies = {
        "nvim-telescope/telescope.nvim",
    },
    after = "nvim-telescope/telescope.nvim",
    keys = {
        { "<leader>tf", function() require("telescope").extensions.worktrees.list_worktrees() end, desc = "find worktrees", },
        { "<leader>tw", function() require("worktrees").new_worktree(true) end,                    desc = "create worktrees", },
    },
    opts = {},
}
