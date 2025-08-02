return {
    'pwntester/octo.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
    },
    keys = {
        { "<leader>tc", "<CMD>Octo<CR>", desc = "Octo commands", mode = "n" },
    },
    cond = function()
        return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("\n", "") == "true"
    end,
    opts = {
        enable_builtin = true
    },
}
