local lsp_config = require "adev.config.lspconfig"
local plugin = require "adev-common.plugin"

local function lsp_key(lhs, method, desc, mode)
    return {
        lhs,
        function()
            vim.lsp.buf[method]()
        end,
        desc = desc,
        mode = mode,
    }
end

local function diagnostic_key(lhs, count, desc)
    return {
        lhs,
        function()
            vim.diagnostic.jump { count = count, float = true }
        end,
        desc = desc,
    }
end

return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "mason-org/mason-lspconfig.nvim",
        "saghen/blink.cmp",
    },
    event = plugin.file_events(),
    config = lsp_config,
    keys = {
        {
            "<leader>gl",
            function()
                -- NOTE: a super high timeout is set thanks to prettier being blazingly fast
                vim.lsp.buf.format { timeout_ms = 10000 }
            end,
            desc = "lint buffer",
            mode = { "v", "n" },
        },
        lsp_key("<leader>gd", "definition", "go to definition"),
        lsp_key("<leader>gD", "declaration", "go to declaration"),
        lsp_key("<leader>gh", "hover", "lsp hover"),
        lsp_key("<leader>gi", "implementation", "lsp implementation"),
        lsp_key("<leader>gr", "references", "lsp references"),
        lsp_key("<leader>gt", "type_definition", "lsp type definition"),
        lsp_key("<leader>gc", "code_action", "lsp code action", { "n", "v" }),
        lsp_key("<leader>gs", "signature_help", "lsp signature help"),
        {
            "<leader>go",
            function()
                vim.diagnostic.open_float()
            end,
            desc = "line diagnostic",
        },
        diagnostic_key("<leader>gp", -1, "previous diagnostic"),
        diagnostic_key("<leader>gn", 1, "next diagnostic"),
        lsp_key("<leader>ga", "rename", "lsp rename"),
        {
            "<leader>ms",
            function()
                for _, client in ipairs(vim.lsp.get_clients()) do
                    print(client.name)
                end
            end,
            desc = "lsp info",
        },
    },
}
