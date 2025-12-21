---@type SetupOpts
local defaults = {
    git = "git",
    mapleader = " ",
    auto_update_check = true,
    colorscheme = "catppuccin",
    catppuccin = {
        enable = true,
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
        servers = nil,
        enable = true,
    },
    ai_assistant = {
        enabled = false,
        plugin = "augmentcode/augment.vim",
        command = "Augment",
        opts = nil,
    },
}

return defaults
