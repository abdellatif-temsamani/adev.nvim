return {
    'isakbm/gitgraph.nvim',
    cond = function()
        return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("\n", "") == "true"
    end,
    opts = {
        symbols = {
            merge_commit = 'M',
            commit = '*',
        },
        format = {
            timestamp = '%H:%M:%S %d-%m-%Y',
            fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
        },
        hooks = {
            on_select_commit = function(commit)
                vim.notify('selected commit:', commit.hash)
            end,
            on_select_range_commit = function(from, to)
                vim.notify('selected range:', from.hash, to.hash)
            end,
        },
    },
    keys = {
        {
            "<leader>tg",
            function()
                require('gitgraph').draw({}, { all = true, max_count = 5000 })
            end,
            desc = "GitGraph - Draw",
        },
    },
}
