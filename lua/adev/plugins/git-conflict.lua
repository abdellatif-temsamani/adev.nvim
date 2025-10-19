local events = require "adev.utils.consts.events"
return {
    "akinsho/git-conflict.nvim",
    version = "*",
    cond = function()
        return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("\n", "") == "true"
    end,
    opts = {},
    ft= "gitcommit",
    event = { events.file.type },
}
