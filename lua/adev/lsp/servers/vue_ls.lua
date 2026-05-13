return require("adev.lsp.servers.configure").server("vue_ls", {
    init_options = {
        typescript = {
            tsdk = vim.uv.os_homedir()
                .. "/.local/share/nvim/mason/packages/vue-language-server/node_modules/typescript/lib",
        },
    },
})
