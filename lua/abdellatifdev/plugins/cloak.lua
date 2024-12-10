return {
    "laytan/cloak.nvim",
    event = { "BufEnter .env*" },
    lazy = true,
    opts = {
        enabled = true,
        cloak_character = "*",
        highlight_group = "Comment",
        patterns = {
            {
                file_pattern = {
                    ".env*",
                },
                cloak_pattern = { "=.+" }
            },
        },
    }
}
