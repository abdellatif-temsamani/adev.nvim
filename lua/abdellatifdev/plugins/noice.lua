return
{
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
        notify = {
            enabled = false,
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
