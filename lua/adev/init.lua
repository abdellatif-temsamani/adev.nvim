local _commands = require "adev.commands"

local M = {}

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

    require("adev.utils").setup_lazy()
    _commands.register()

    vim.cmd [[ colorscheme catppuccin-mocha ]]
end

return M
