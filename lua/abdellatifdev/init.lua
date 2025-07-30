---Module metadata and public interface.
local M = {
    _AUTHOR = "Abdellatif Dev", ---@type string
    _VERSION = "1.0.0", ---@type string
}

---Display author and version information using `vim.notify`.
---
---This is primarily for debugging or user reference.
function M:info()
    vim.notify(
        "\n" ..
        "Author: " .. self._AUTHOR .. "\n" ..
        "Version: " .. self._VERSION,
        vim.log.levels.INFO
    )
end

---@private
---Bootstraps and sets up the lazy.nvim plugin manager.
---
---This function ensures that `lazy.nvim` is installed in the standard data path.
---If not, it clones the stable branch from GitHub. It then prepends it to the runtime path
---and initializes it with your plugin spec.
---
---If the clone fails, it notifies the user and exits Neovim.
function M.__setup_lazy()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    ---@diagnostic disable-next-line: undefined-field
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


    -- Setup lazy.nvim
    require("lazy").setup({
        spec = {
            { import = "abdellatifdev.plugins" },
        },
        install = { colorscheme = { "tokyonight" } },
        checker = { enabled = true },
    })
end

---Setup Neovim core settings and bootstrap plugins.
---
---This function enables Lua module caching, configures UI options,
---sets key mapping leaders, and initializes lazy.nvim plugin manager.
function M.setup()
    vim.loader.enable(true)
    vim.opt.termguicolors = true
    vim.o.winbar = " "
    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"

    M.__setup_lazy()
end

return M
