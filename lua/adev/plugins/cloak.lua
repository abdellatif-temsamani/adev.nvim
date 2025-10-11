return {
    "laytan/cloak.nvim",
    event = require "adev.utils.consts.events".buffer._enter(".env*"),
    cond = function()
        local files = vim.fn.glob(".env*", false, true)
        return #files > 0
    end,
    opts = {
        enabled = true,
        cloak_character = "*",
        highlight_group = "Comment",
        patterns = {
            {
                file_pattern = {
                    ".env*",
                },
                cloak_pattern = { "=.+" }
            },
        },
    }
}
