return {
    'brenoprata10/nvim-highlight-colors',
    ft = {
        'css', 'scss', 'sass', 'less', 'html', 'typescript', 'typescriptreact',
        'javascript', 'javascriptreact', 'vue', 'markdown', 'php'
    },
    lazy = true,
    opts = {
        render = 'background',
        enable_named_colors = true,
        enable_tailwind = true,
    }
}
