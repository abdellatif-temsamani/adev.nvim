return {
    "folke/noice.nvim",
    event = require("adev.utils.events").vim.lazy,
    cmd = { "NoiceTelescope" },
    keys = {
        { "<leader>fn", "<cmd>NoiceTelescope<cr>", desc = "notifications history" },
    },
    opts = {
        lsp = {
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
            },
        },
        notify = {
            enabled = true,
        },
        cmdline = {
            enabled = true,
            view = "cmdline",
        },
        presets = {
            lsp_doc_border = true,
        },
    },
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
}
