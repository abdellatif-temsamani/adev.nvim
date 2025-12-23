local events = require "adev.utils.events"

return {
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { events.buffer.new_file, events.buffer.read_pre, events.file.read_pre },
        opts = {
            enable = true,
            max_lines = 2,
            zindex = 20,
        },
    },
    {
        "windwp/nvim-ts-autotag",

        event = { events.buffer.new_file, events.buffer.read_pre, events.file.read_pre },
        opts = {
            per_filetype = {
                ["blade"] = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
                ["xml"] = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
            },
        },
    },
    {
        "nvim-treesitter/nvim-treesitter",
        event = { events.buffer.new_file, events.buffer.read_pre, events.file.read_pre },
        build = ":TSUpdate",
        opts = {
            sync_install = false,
            ensure_installed = "all",
            auto_install = true,
            indent = { enable = true },
            context_commentstring = {
                enable = true,
                enable_autocmd = false,
            },
            ignore_install = { "zimbu" },
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
        },
        config = function(_, opts)
            local treesitter = require "nvim-treesitter.configs"
            treesitter.setup(opts)
        end,
    },
}
