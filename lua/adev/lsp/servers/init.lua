local capabilities = require "adev.lsp.capabilities"

local M = {}

local servers = {
    "lua_ls",
    "tailwindcss",
    "vue_ls",
    "emmet_ls",
    "html",
    "pylsp",
    "texlab",
    "intelephense",
}

function M.setup()
    if not vim.lsp.inlay_hint.is_enabled() then
        vim.lsp.inlay_hint.enable(true)
    end
    vim.diagnostic.config {
        virtual_text = {
            current_line = true,
        },
    }

    vim.lsp.config("*", {
        capabilities = capabilities.build(),
    })

    for _, server in ipairs(servers) do
        require("adev.lsp.servers." .. server)()
    end
end

return M
