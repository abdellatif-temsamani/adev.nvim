local events = require "adev.utils.consts.events"
---@diagnostic disable: param-type-mismatch
return {
    "lewis6991/gitsigns.nvim",
    cond = function()
        return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("\n", "") == "true"
    end,
    event = { events.buffer.read_pre, events.buffer.new_file, },
    keys = {
        { "<leader>tn",  function() require "gitsigns".nav_hunk("next") end,            desc = "next hunk", },
        { "<leader>tp",  function() require "gitsigns".nav_hunk("prev") end,            desc = "previous hunk", },
        { "<leader>tr",  function() require "gitsigns".reset_hunk() end,                desc = "reset hunk", },
        { "<leader>ts",  function() require "gitsigns".stage_hunk() end,                desc = "stage hunk", },
        { "<leader>tv",  function() require "gitsigns".select_hunk() end,               desc = "select hunk", },
        { "<leader>th",  function() require "gitsigns".preview_hunk() end,              desc = "preview hunk", },
        { "<leader>td",  function() require "gitsigns".diffthis() end,                  desc = "diff this", },
        { "<leader>tl",  function() require "gitsigns".blame_line { full = false } end, desc = "blame line", },
        { "<leader>tbs", function() require "gitsigns".stage_buffer() end,              desc = "stage buffer", },
        { "<leader>tbr", function() require "gitsigns".reset_buffer() end,              desc = "reset buffer", },
    },
    opts = {
        current_line_blame = false,
        current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol",
            delay = 500,
            ignore_whitespace = false
        }
    }
}
