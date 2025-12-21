---@class PackageManagerOpts refere to lazy.nvim setup options
---@field git string?  Path or command for Git executable (default: "git")
---@field lazy LazyOpts?  LazyNvim enabled (default: true)

---@param opts PackageManagerOpts
return function(opts)
    local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system {
            opts.git,
            "clone",
            "--filter=blob:none",
            "--branch=stable",
            lazyrepo,
            lazypath,
        }
        if vim.v.shell_error ~= 0 then
            vim.api.nvim_echo({
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out, "WarningMsg" },
                { "\nPress any key to exit..." },
            }, true, {})
            vim.fn.getchar()
            os.exit(1)
        end
    end
    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup {
        defaults = {
            lazy = opts.lazy.lazy_loading,
            version = opts.lazy.plugin_version,
        },

        rocks = {
            enabled = true,
            root = vim.fn.stdpath "data" .. "/lazy-rocks",
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
            { import = "adev.custom-plugins" },
        },
        ui = {
            border = Adev.ui.border,
            title = "Adev.nvim",
        },
        performance = {
            cache = {
                enabled = true,
            },
        },
        install = { colorscheme = { "catppuccin-mocha" } },
        checker = { enabled = opts.lazy.auto_update_check },
    }
end
