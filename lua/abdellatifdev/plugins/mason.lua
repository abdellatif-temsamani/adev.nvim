return {
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

    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        event = require("abdellatifdev.consts").events.pre,
        after = "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "bash-debug-adapter",
                "chrome-debug-adapter",
                "codelldb",
                "debugpy",

            }
        }
    },
    {
        "jay-babu/mason-null-ls.nvim",
        event = require("abdellatifdev.consts").events.pre,
        after = "williamboman/mason.nvim",
        dependencies = {
            "williamboman/mason.nvim",
            "nvimtools/none-ls.nvim",
        },
        opts = {
            ensure_installed = {
                "actionlint",
                "checkmake",
                "djlint",
                "gitlint",
                "hadolint",
                "npm-groovy-lint",
                "phpcs",
                "phpmd",
                "proselint",
                "prettier",
                "prettierd",
                "pyre",
                "pretty_php",
                "shellharden",
                "yamllint",
                "alex",
            }
        }
    },
    {
        "williamboman/mason-lspconfig.nvim",
        event = require("abdellatifdev.consts").events.pre,
        after = "williamboman/mason.nvim",
        opts = {
            automatic_enable = false,
            ensure_installed = {
                "intelephense",
                "lua_ls",
                "vtsls",
                "csharp_ls",
                "volar",
                "htmx",
                "ts_ls",
                "emmet_ls",
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

}
