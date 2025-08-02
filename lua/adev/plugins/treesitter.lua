local function treesitter_setup()
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup({
        sync_install          = false,
        ensure_installed      = "all",
        auto_install          = true,
        indent                = { enable = true },
        context_commentstring = {
            enable = true,
            enable_autocmd = false
        },
        ignore_install        = { "zimbu" },
        highlight             = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
    })
end

return {
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = require("adev.consts").events.file,
        opts = {
            enable = true,
            max_lines = 2,
            zindex = 20,
        }
    },
    {
        'windwp/nvim-ts-autotag',

        event = require("adev.consts").events.file,
        opts = {
            per_filetype = {
                ["blade"] = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false
                },
                ["xml"] = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false
                }
            }
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        event = require("adev.consts").events.file,
        build = ":TSUpdate",
        config = treesitter_setup,
    },
}
