return {
    'davidsierradz/cmp-conventionalcommits',
    enabled = true,
    ft = "gitcommit",
    cond = function()
        return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("\n", "") == "true"
    end,
    dependencies = {
        "hrsh7th/nvim-cmp",
    },
}
