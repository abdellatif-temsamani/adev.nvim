return {
    "folke/noice.nvim",
    event = require("adev-common.utils.events").vim.lazy,
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
        views = {
            popup = {
                border = {
                    style = Adev.ui.border,
                },
            },
            hover = {
                border = {
                    style = Adev.ui.border,
                },
            },
            mini = {
                border = {
                    style = Adev.ui.border,
                },
            },
            cmdline_popup = {
                border = {
                    style = Adev.ui.border,
                },
            },
        },
    },
    dependencies = {
        "MunifTanjim/nui.nvim",
    },
}
