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
            disable = function(lang, buf)
                local max_filesize = 100 * 1024 -- 100 KB
                ---@diagnostic disable-next-line: undefined-field
                local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
        },
    })

    local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
    ---@diagnostic disable-next-line: inject-field
    parser_config.blade = {
        install_info = {
            url = "https://github.com/EmranMR/tree-sitter-blade",
            files = { "src/parser.c" },
            branch = "main",
        },
        filetype = "blade",
    }

    vim.filetype.add({
        pattern = {
            [".*%.blade%.php"] = "blade",
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
        "windwp/nvim-autopairs",
        event = require("abdellatifdev.consts").events.file,
        opts = {
            disable_filetype = { "TelescopePrompt" },
            ignored_next_char = string.gsub([[ [%w%%%'%[%"%.] ]], "%s+", ""),
            enable_moveright = true,
            enable_afterquote = true,
            enable_check_bracket_line = true,
            check_ts = true,
            ts_config = {
                lua = { "string" },
                javascript = { "template_string" }
            }
        }
    },
    {
        'windwp/nvim-ts-autotag',

        event = require("abdellatifdev.consts").events.file,
        opts = {},
    },
    {
        "nvim-treesitter/nvim-treesitter",
        event = require("abdellatifdev.consts").events.file,
        build = ":TSUpdate",
        config = function()
            treesitter_setup()
        end,
    },
}
