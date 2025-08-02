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
        defaults = {
            lazy = true,
        },

        rocks = {
            enabled = true,
            root = vim.fn.stdpath("data") .. "/lazy-rocks",
            server = "https://nvim-neorocks.github.io/rocks-binaries/",
            hererocks = false,
        },
        pkg = {
            enabled = true,
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
            border = 'single',
            title = "Adev.nvim",

        },
        performance = {
            cache = {
                enabled = true,
            },
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
    local git_cmd = { "git", "pull", "--ff-only" }

    vim.fn.jobstart(git_cmd, {
        cwd = config_path,
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, data, _)
            if data then
                local lines = vim.tbl_filter(function(line)
                    return line and line ~= ""
                end, data)

                if #lines > 0 then
                    local msg = table.concat(lines, "\n")
                    if msg:find("Already up to date") then
                        vim.notify("Already up to date", vim.log.levels.INFO, { title = "Adev Update" })
                    else
                        vim.notify("Updated successfully:\n", vim.log.levels.INFO, { title = "Adev Update" })
                    end
                end
            end
        end,
        on_stderr = function(_, data, _)
            if data then
                local lines = vim.tbl_filter(function(line)
                    return line and line ~= ""
                end, data)

                if #lines > 0 then
                    local msg = table.concat(lines, "\n")
                    vim.notify("Git error:\n" .. msg, vim.log.levels.ERROR, { title = "Adev Update" })
                end
            end
        end,
        on_exit = function(_, code, _)
            if code ~= 0 then
                vim.notify("Git pull failed with exit code: " .. code, vim.log.levels.ERROR, { title = "Adev Update" })
            end
        end,
    })
end


return {
    setup_lazy = setup_lazy,
    update_adev = update_adev,
}
