local events = require "adev.utils.consts.events"

return {
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { events.file.read_pre, },
        opts = {
            enable = true,
            max_lines = 2,
            zindex = 20,
        }
    },
    {
        "windwp/nvim-ts-autotag",

        event = { events.file.read_pre, },
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
        event = { events.file.read_pre, },
        build = ":TSUpdate",
        config = function()
            require "adev.config.treesitter".setup()
        end,
    },
}
