---Bootstraps and sets up the lazy.nvim plugin manager.
---
---This function ensures that `lazy.nvim` is installed in the standard data path.
---If not, it clones the stable branch from GitHub. It then prepends it to the runtime path
---and initializes it with your plugin spec.
---
---If the clone fails, it notifies the user and exits Neovim.
local function setup_lazy()
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
local function update_adev()
    local config_path = vim.fn.stdpath("config")
    local git_cmd = { "git", "pull", "--ff-only" }

    local stderr_lines = {}

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
                        vim.notify("Already up to date", vim.log.levels.INFO, { title = "adev.nvim" })
                    else
                        vim.notify("Updated successfully:\n" .. msg, vim.log.levels.INFO, { title = "adev.nvim" })
                    end
                end
            end
        end,
        on_stderr = function(_, data, _)
            if data then
                for _, line in ipairs(data) do
                    if line and line ~= "" then
                        table.insert(stderr_lines, line)
                    end
                end
            end
        end,
        on_exit = function(_, code, _)
            if code ~= 0 then
                local msg = table.concat(stderr_lines, "\n")
                if msg == "" then msg = "Unknown error" end
                vim.notify("Git pull failed:\n" .. msg, vim.log.levels.ERROR, { title = "adev.nvim" })
            end
        end,
    })
end


--- Checks if Adev's config directory has updates from its GitHub remote.
--- Runs `git fetch` and compares `HEAD` against `origin/HEAD`.
--- Sends a desktop notification if updates are available.
---@return nil
--- Check for updates in Neovim's config asynchronously
---@return nil
local function check_adev_update()
    ---@type string
    local config_path = vim.fn.stdpath("config")

    -- Step 1: fetch remote refs
    vim.system({ "git", "-C", config_path, "fetch", "origin" }, { text = true }, function(fetch_result)
        if fetch_result.code ~= 0 then
            vim.schedule(function()
                vim.notify("Failed to fetch updates: " .. (fetch_result.stderr or ""), vim.log.levels.ERROR, {
                    title = "adev.nvim",
                })
            end)
            return
        end

        -- Step 2: check how many commits we're behind
        vim.system({ "git", "-C", config_path, "rev-list", "HEAD..origin/HEAD", "--count" }, { text = true },
            function(check_result)
                if check_result.code ~= 0 then
                    vim.schedule(function()
                        vim.notify("Failed to check updates: " .. (check_result.stderr or ""), vim.log.levels.ERROR, {
                            title = "adev.nvim",
                        })
                    end)
                    return
                end

                local updates = tonumber((check_result.stdout or ""):match("%d+"))
                if updates and updates > 0 then
                    vim.schedule(function()
                        vim.notify("There are " .. updates .. " new commits available in your config!",
                            vim.log.levels.INFO, {
                                title = "adev.nvim",
                            })
                    end)
                end
            end)
    end)
end



return {
    setup_lazy = setup_lazy,
    update_adev = update_adev,
    check_adev_update = check_adev_update,
}
