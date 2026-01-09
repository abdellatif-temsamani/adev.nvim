---@type SetupOpts
local defaults = {
    git = "git",
    mapleader = " ",
    auto_update_check = true,
    colorscheme = "catppuccin",
    catppuccin = {
        enabled = true,
        flavour = "mocha",
        transparent = false,
    },
    ui = {
        border = "single",
    },
    lazy = {
        lazy_loading = true,
        auto_update_check = true,
        plugin_version = nil,
    },
    lsp = {
        enable = true,
    },
    ai_assistant = {
        enabled = false,
        plugin = "augmentcode/augment.vim",
        command = "Augment",
        opts = nil,
    },
    flags = {
        experimental_adev_files = false,
    },
}

return defaults
