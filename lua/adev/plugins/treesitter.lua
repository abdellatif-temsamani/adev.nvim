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
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("adev.config.treesitter").setup()
        end,
    },
}
