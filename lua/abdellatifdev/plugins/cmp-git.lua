return {
    "hrsh7th/cmp-git",
    enabled = true,
    cond = function()
        return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("\n", "") == "true"
    end,
    ft = { "gitcommit" },
    opt = {},
    dependencies = {
        "hrsh7th/nvim-cmp",
    },
}
