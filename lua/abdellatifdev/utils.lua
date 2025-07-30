---Bootstraps and sets up the lazy.nvim plugin manager.
---
---This function ensures that `lazy.nvim` is installed in the standard data path.
---If not, it clones the stable branch from GitHub. It then prepends it to the runtime path
---and initializes it with your plugin spec.
---
---If the clone fails, it notifies the user and exits Neovim.
---@param git "git" | string
local function setup_lazy(git)
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    ---@diagnostic disable-next-line: undefined-field
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ git, "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
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


--- Update the Adev Neovim configuration by performing a git pull.
---
--- Runs `git pull --ff-only` asynchronously inside the Neovim config directory (`~/.config/nvim`),
--- then displays the command output in a floating window using Snacks.nvim.
---
---@param git "git" | string
local function update_adev(git)
    git = git or "git"

    local config_path = vim.fn.stdpath('config')
    vim.fn.jobstart({ git, "pull", "--ff-only" }, {
        cwd = config_path,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data, _)
            if data then
                for _, line in ipairs(data) do
                    if line and line ~= "" then
                        vim.notify(line)
                    end
                end
            end
        end,
        on_stderr = function(_, data, _)
            if data then
                for _, line in ipairs(data) do
                    if line and line ~= "" then
                        vim.notify(line)
                    end
                end
            end
        end,
    })
end


return {
    setup_lazy = setup_lazy,
    update_adev = update_adev,
}
