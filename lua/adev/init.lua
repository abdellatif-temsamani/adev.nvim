local defaults = require "adev.defaults"
local update_manager = require "adev.update_manager"
local err_notify = require("adev.utils").err_notify

local M = {}

---@param opts SetupOpts?
function M.setup(opts)
    assert(opts, "opts is nil")
    ---@type SetupOpts
    opts = vim.tbl_deep_extend("force", {}, defaults, opts or {})

    vim.g.mapleader = opts.mapleader
    vim.g.maplocalleader = opts.mapleader

    --- NOTE: fixes layout shifts
    vim.o.winbar = " "
    vim.o.winborder = opts.ui.border

    ---@type Adev
    _G.Adev = {
        git = opts.git,
        ai_assistant = opts.ai_assistant,
        catppuccin = opts.catppuccin,
        ui = opts.ui,
    }

    if vim.fn.executable(opts.git) == 0 then
        err_notify "git is not installed"
        err_notify "Install git"
        err_notify "And set git path in init.lua"
        err_notify 'in require "adev.".setup'
        err_notify '{ git = "/path/to/git" }'

        return
    end

    require("adev.commands"):setup()
    if opts.auto_update_check then
        update_manager.check_update()
    end

    require "adev.lazy" {
        git = opts.git,
        lazy = opts.lazy,
    }

    if opts.lsp.enable then
        require("adev.lsp").setup(opts.lsp.servers)
    end

    require("adev-files").setup()
    if not opts.catppuccin.enabled and opts.colorscheme == "catppuccin" then
        opts.colorscheme = "default"
    end
    vim.cmd(string.format("colorscheme %s", opts.colorscheme))
end

return M
