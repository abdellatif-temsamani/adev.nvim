local events = require "adev.utils.events"

local alts = {
    FIX = { "FIXME", "BUG", "FIXIT", "ISSUE", "ERROR" },
    DONE = { "DONE", "DONE!", "DONE.", "FIXED", "WONTFIX" },
    TODO = { "PLAN", "TODO", "TASK", "START", "BEGIN" },
    WARN = { "WARNING", "WARN", "HACK" },
    PREF = { "PERF", "OPTIM", "OPTIMIZE", "PERFORMANCE" },
    INFO = { "INFO", "NOTE", "NOTES", "HINT", "TIP" },
    TEST = { "TESTING", "PASSED", "FAILED" },
}

return {
    "folke/todo-comments.nvim",
    event = { events.buffer.new_file, events.buffer.read_pre, events.file.read_pre },
    dependencies = { "nvim-telescope/telescope.nvim" },
    cmd = { "TodoTelescope" },
    keys = {
        { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find todo comments" },
    },
    opts = {
        signs = true,
        sign_priority = 8,
        keywords = {
            FIX = { icon = "", color = "error", alt = alts.FIX },
            DONE = { icon = "", color = "hint", alt = alts.DONE },
            TODO = { icon = "", color = "info", alt = alts.TODO },
            WARN = { icon = "", color = "warning", alt = alts.WARN },
            PREF = { icon = "", alt = alts.PREF },
            NOTE = { icon = " ", color = "hint", alt = alts.INFO },
            TEST = { icon = "⏲ ", color = "test", alt = alts.TEST },
        },
        merge_keywords = true,
        highlight = {
            before = "fg",
            keyword = "bg",
            after = "fg",
            pattern = [[.*<(KEYWORDS)\s*:]],
            comments_only = true,
            max_line_len = 400,
        },
        search = {
            command = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
            },
            pattern = [[\b(KEYWORDS):]],
        },
    },
}
