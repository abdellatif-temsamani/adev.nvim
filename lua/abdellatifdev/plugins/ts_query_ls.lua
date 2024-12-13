return {
    "ribru17/ts_query_ls",
    ft = 'query',
    module = false,
    config = function()
        vim.api.nvim_create_autocmd('FileType', {
            pattern = 'query',
            callback = function(ev)
                local capabilities = require("cmp_nvim_lsp").default_capabilities()
                capabilities.textDocument.completion.completionItem.snippetSupport = true

                local function on_attach(client, bufnr)
                    if client.server_capabilities.documentSymbolProvider then
                        require("nvim-navic").attach(client, bufnr)
                    end
                end


                if vim.bo[ev.buf].buftype == 'nofile' then
                    return
                end
                vim.lsp.start {
                    capabilities = capabilities,
                    on_attach = on_attach,
                    name = 'ts_query_ls',
                    cmd = { 'ts_query_ls' },
                    root_dir = vim.fs.root(0, { 'queries' }),
                    settings = {
                        parser_install_directories = {
                            -- If using nvim-treesitter with lazy.nvim
                            vim.fs.joinpath(
                            ---@diagnostic disable-next-line: param-type-mismatch
                                vim.fn.stdpath('data'),
                                '/lazy/nvim-treesitter/parser/'
                            ),
                        },
                        parser_aliases = {
                            ecma = 'javascript',
                        },
                        language_retrieval_patterns = {
                            'languages/src/([^/]+)/[^/]+\\.scm$',
                        },
                    },
                }
            end,
        })
    end

}
