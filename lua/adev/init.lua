local _commands = require "adev.commands"


local M = {}

function M.setup_lazy()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out,                            "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end
    vim.opt.rtp:prepend(lazypath)


    require "lazy".setup({
        defaults = {
            lazy = true,
            version = "*",
        },

        rocks = {
            enabled = true,
            root = vim.fn.stdpath("data") .. "/lazy-rocks",
            server = "https://nvim-neorocks.github.io/rocks-binaries/",

            hererocks = true,
        },
        pkg = {
            enabled = true,
            cache = vim.fn.stdpath("state") .. "/lazy/pkg-cache.lua",
            sources = {
                "lazy",
                "rockspec",
                "packspec",
            },
        },
        spec = {
            { import = "adev.plugins" },
        },
        ui = {
            border = "single",
            title = "Adev.nvim",

        },
        performance = {
            cache = {
                enabled = true,
            },
        },
        install = { colorscheme = { "catppuccin-mocha" } },
        checker = { enabled = true },
    })
end

---Setup Neovim core settings and bootstrap plugins.
---
---This function enables Lua module caching, configures UI options,
---sets key mapping leaders, and initializes lazy.nvim plugin manager.
function M.setup()
    vim.g.Adev = {
        _NAME = "Adev.nvim",
        _AUTHOR = "Abdellatif Dev",
        _VERSION = "1.4.0",
    }

    M.setup_lazy()

    _commands.register()

    vim.cmd [[ colorscheme catppuccin-mocha ]]
end

return M
