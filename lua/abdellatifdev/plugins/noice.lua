return
{
    "folke/noice.nvim",
    event = "VeryLazy",
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
            lsp_doc_border = true, -- add a border to hover docs and signature help
        },
    },
    dependencies = {
        "MunifTanjim/nui.nvim",
    }
}
