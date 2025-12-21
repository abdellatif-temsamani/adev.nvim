local events = require "adev.utils.events"
local lsp_config = require "adev.config.lspconfig"

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "mason-org/mason-lspconfig.nvim",
        "saghen/blink.cmp",
    },
    event = { events.buffer.new_file, events.buffer.read_pre, events.file.read_pre },
    config = lsp_config,
    keys = {
        {
            "<leader>gl",
            function()
                vim.lsp.buf.format()
            end,
            desc = "lint buffer",
            mode = { "v", "n" },
        },
        {
            "<leader>gd",
            function()
                vim.lsp.buf.definition()
            end,
            desc = "go to definition",
        },
        {
            "<leader>gD",
            function()
                vim.lsp.buf.declaration()
            end,
            desc = "go to declaration",
        },
        {
            "<leader>gh",
            function()
                vim.lsp.buf.hover()
            end,
            desc = "lsp hover",
        },
        {
            "<leader>gi",
            function()
                vim.lsp.buf.implementation()
            end,
            desc = "lsp implementation",
        },
        {
            "<leader>gr",
            function()
                vim.lsp.buf.references()
            end,
            desc = "lsp implementation",
        },
        {
            "<leader>gt",
            function()
                vim.lsp.buf.type_definition()
            end,
            desc = "lsp type definition",
        },
        {
            "<leader>gc",
            function()
                vim.lsp.buf.code_action()
            end,
            desc = "lsp code action",
            mode = { "n", "v" },
        },
        {
            "<leader>gs",
            function()
                vim.lsp.buf.signature_help()
            end,
            desc = "lsp signature help",
        },
        {
            "<leader>go",
            function()
                vim.diagnostic.open_float()
            end,
            desc = "line diagnostic",
        },
        {
            "<leader>gp",
            function()
                vim.diagnostic.jump { count = -1, float = true }
            end,
            desc = "previous diagnostic",
        },
        {
            "<leader>gn",
            function()
                vim.diagnostic.jump { count = 1, float = true }
            end,
            desc = "next diagnostic",
        },
        {
            "<leader>ga",
            function()
                vim.lsp.buf.rename()
            end,
            desc = "lsp rename",
        },
        {
            "<leader>gt",
            function()
                vim.lsp.buf.type_definition()
            end,
            desc = "lsp type definition",
        },
        {
            "<leader>ms",
            "<cmd>LspInfo<cr>",
            desc = "lsp type definition",
        },
    },
}
