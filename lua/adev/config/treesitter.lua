local function setup()
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup {
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
    }
end

return { setup = setup }
