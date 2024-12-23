local function is_i3config()
    return vim.uv.cwd() == vim.fn.getenv("HOME") .. "/dotfiles/i3/.config/i3"
end

return {
    {
        dir = "~/programming/twitch/tree-sitter-i3config/",
        event = { "BufEnter i3config", "BufEnter grammar.js" },
        lazy = not is_i3config(),
        cond = function()
            --- only loads for me
            return vim.fn.system("whoami"):gsub("\n", "") == "flagmate"
        end,

        dependencies = {
            "nvim-treesitter/nvim-treesitter"
        },
        config = function()
            ---@module "i3config"
            require("i3config").setup {
                debugging = true
            }
        end
    }
}
