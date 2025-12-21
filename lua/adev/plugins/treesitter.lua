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
        opts = {},
        config = function()
            local autocmd = vim.api.nvim_create_autocmd
            autocmd(events.file.type, {
                pattern = "*",
                callback = function(args)
                    if vim.bo[args.buf].buftype ~= "" then
                        return
                    end
                    vim.treesitter.start()
                end,
            })
        end,
    },
}
