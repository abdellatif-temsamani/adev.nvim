return {
    "lewis6991/gitsigns.nvim",
    cond = function()
        return vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):gsub("\n", "") == "true"
    end,
    lazy = true,
    event = require("abdellatifdev.consts").file_event,
    keys = {
        { "<leader>gn",  function() require('gitsigns').nav_hunk("next") end,           desc = "next hunk", },
        { "<leader>gp",  function() require('gitsigns').nav_hunk("prev") end,           desc = "previous hunk", },
        { "<leader>gr",  function() require('gitsigns').reset_hunk() end,               desc = "reset hunk", },
        { "<leader>gs",  function() require('gitsigns').stage_hunk() end,               desc = "stage hunk", },
        { "<leader>gv",  function() require('gitsigns').select_hunk() end,              desc = "select hunk", },
        { "<leader>gh",  function() require('gitsigns').preview_hunk() end,             desc = "preview hunk", },
        { "<leader>gD",  function() require('gitsigns').toggle_deleted() end,           desc = "gitsigns toggle deleted", },
        { "<leader>gd",  function() require('gitsigns').diffthis() end,                 desc = "diff this", },
        { "<leader>gl",  function() require('gitsigns').blame_line { full = true } end, desc = "blame line", },
        { "<leader>gu",  function() require('gitsigns').undo_stage_hunk() end,          desc = "undo stage hunk", },
        { "<leader>gbs", function() require('gitsigns').stage_buffer() end,             desc = "stage buffer", },
        { "<leader>gbr", function() require('gitsigns').reset_buffer() end,             desc = "reset buffer", },

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
