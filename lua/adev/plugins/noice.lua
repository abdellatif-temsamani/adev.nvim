return
{
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
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
    }
}
