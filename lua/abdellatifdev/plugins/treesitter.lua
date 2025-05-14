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
            disable = function(_, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                ---@diagnostic disable-next-line: undefined-field
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
        },
    })
end

return {
    {
        "nvim-treesitter/nvim-treesitter-context",
        event = require("abdellatifdev.consts").events.file,
        opts = {
            enable = true,
            max_lines = 2,
            zindex = 20,
        }
    },
    {
        'windwp/nvim-ts-autotag',

        event = require("abdellatifdev.consts").events.file,
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
        event = require("abdellatifdev.consts").events.file,
        build = ":TSUpdate",
        config = treesitter_setup,
    },
}
