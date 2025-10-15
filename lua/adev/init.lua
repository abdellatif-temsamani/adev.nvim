local _commands = require "adev.commands"

local M = {}

function M.setup_lazy()
    local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system {
            vim.g.Adev.config.core.git,
            "clone",
            "--filter=blob:none",
            "--branch=stable",
            lazyrepo,
            lazypath,
        }
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

    require("lazy").setup {
        defaults = {
            lazy = true,
            -- TODO: add as opts
            -- version = "*",
        },

        rocks = {
            enabled = true,
            root = vim.fn.stdpath "data" .. "/lazy-rocks",
            server = "https://nvim-neorocks.github.io/rocks-binaries/",

            hererocks = true,
        },
        pkg = {
            enabled = true,
            cache = vim.fn.stdpath "state" .. "/lazy/pkg-cache.lua",
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
    }
end

--- Configuration options for Adev.nvim setup.
--- @class SetupOpts
--- @field core CoreOpts Core configuration options.

--- @class CoreOpts
--- @field git string | "git" | nil Path or command for Git executable (default: "git").
--- @field mapleader string | " " | nil Leader key (default: " ").
--- @field check_update boolean | true | nil Check for Adev.nvim updates on startup (default: true).

---Setup Adev.nvim core settings and bootstrap plugins.
--- @param opts SetupOpts? Table of options.
--- @return nil
function M.setup(opts)
    opts = opts or {
        core = {},
    }

    opts.core.git = opts.core.git or "git"
    opts.core.mapleader = opts.core.mapleader or " "
    opts.core.check_update = opts.core.check_update or true

    vim.loader.enable(true)
    vim.o.winbar = opts.core.mapleader
    vim.g.mapleader = opts.core.mapleader
    vim.g.maplocalleader = opts.core.mapleader
    vim.opt.termguicolors = true

    vim.g.Adev = {
        _NAME = "Adev.nvim",
        _AUTHOR = "Abdellatif Dev",
        _VERSION = "1.5.0",
        config = {
            core = opts.core,
        },
    }

    if opts.core.check_update then
        require("adev.utils.update").check_adev_update()
    end

    M.setup_lazy()

    _commands.register()

    vim.cmd "colorscheme catppuccin"
end

return M
