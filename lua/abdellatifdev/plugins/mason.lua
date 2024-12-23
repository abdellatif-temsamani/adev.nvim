return {
    "williamboman/mason-lspconfig.nvim",
    event = require("abdellatifdev.consts").events.pre,
    dependencies = {
        {
            "williamboman/mason.nvim",
            build = ":MasonUpdate",
            cmd = "Mason",
            event = require("abdellatifdev.consts").events.pre,
            opts = {
                ui = {
                    check_outdated_packages_on_open = true,
                    border = "none",
                },
            },

        }
    },
    opts = {
        ensure_installed = {
            "lua_ls",
            "csharp_ls",
            "volar",
            "htmx",
            "astro",
            "svelte",
            "svlangserver",
            "svls",
            "bashls",
            "clangd",
            "eslint",
            "cmake",
            "cssmodules_ls",
            "jdtls",
            "dockerls",
            "docker_compose_language_service",
            "html",
            "jsonls",
            "pyre",
            "pylsp",
            "pyright",
            "rust_analyzer",
            "sqlls",
            "stylelint_lsp",
            "cssls",
            "prismals",
            "tailwindcss",
            "taplo",
            "zls",
            "solidity",
            "solidity_ls_nomicfoundation",
            "asm_lsp",
            "yamlls",
            "lemminx",
            "texlab"
        },
    }
}
