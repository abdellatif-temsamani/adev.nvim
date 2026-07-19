return {
    "davidmh/mdx.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = require("adev-common.utils.events").buffer._enter "*.mdx",
}
