local function setup()
    -- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md
    ---module ""
    local null_ls = require("null-ls")
    local h = require("null-ls.helpers")

    local code_actions = null_ls.builtins.code_actions

    -- diagnostic sources
    local diagnostics = null_ls.builtins.diagnostics

    -- formatting sources
    local formatting = null_ls.builtins.formatting

    -- completion sources
    local completion = null_ls.builtins.completion


    -- deno_fmt
    local deno_fmt = require('abdellatifdev.none-ls.deno_fmt')

    null_ls.setup({
        sources = {
            -- diagnostics  -------------
            diagnostics.gitlint,
            diagnostics.actionlint,
            diagnostics.cfn_lint,
            diagnostics.checkmake,
            diagnostics.phpcs,
            diagnostics.phpmd,
            diagnostics.phpstan,
            diagnostics.hadolint,
            diagnostics.yamllint,
            diagnostics.djlint,
            -- formatting  --------------
            formatting.duster,
            formatting.black,
            formatting.cmake_format,
            formatting.isort,
            formatting.blade_formatter,
            formatting.bibclean,
            formatting.phpcbf,
            formatting.phpcsfixer,
            formatting.shellharden,
            formatting.asmfmt,
            formatting.rustywind,
            formatting.djlint,
            formatting.shfmt.with({
                extra_args = { "-i", "4", "-ci" }, -- change to your dialect
            }),
            formatting.cbfmt,
            deno_fmt.with({ filetypes = { "markdown" } }), --
            formatting.sql_formatter,
            formatting.prettier.with({
                args = h.range_formatting_args_factory({
                    "--stdin-filepath", "$FILENAME", "--tab-width", "4",
                    "--embedded-language-formatting", "auto"
                }, "--range-start", "--range-end", {
                    row_offset = -1,
                    col_offset = -1
                }),
                disabled_filetypes = { "markdown" }
            }),
            -- completion  --------------------------------
            completion.tags,
            completion.spell,
            -- code_actions  --------------------------------
            code_actions.gitrebase,
            code_actions.proselint,
        }
    })
end

return { setup = setup }
