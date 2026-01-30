return function()
    vim.lsp.config("vue_ls", {
        init_options = {
            typescript = {
                tsdk = os.getenv "HOME"
                    .. "/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib",
            },
        },
    })
end
