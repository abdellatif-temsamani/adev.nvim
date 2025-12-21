return function()
    local null_setup = require("null-ls").setup
    local builtins = require "null-ls.builtins"
    local h = require "null-ls.helpers"

    local code_actions = builtins.code_actions

    -- diagnostic sources
    local diagnostics = builtins.diagnostics

    -- formatting sources
    local formatting = builtins.formatting

    -- deno_fmt
    local deno_fmt = require "adev.config.none-ls.deno_fmt"
    local gdformat = require "adev.config.none-ls.dgformat"

    null_setup {
        sources = {
            -- diagnostics  -------------
            diagnostics.gitlint,
            diagnostics.actionlint,
            diagnostics.cfn_lint,
            diagnostics.checkmake,
            diagnostics.hadolint,
            diagnostics.gdlint,
            diagnostics.yamllint,
            diagnostics.djlint,
            -- formatting  --------------
            formatting.duster,
            formatting.black,
            formatting.cmake_format,
            formatting.isort,
            formatting.blade_formatter,
            formatting.djhtml,
            formatting.stylua,
            formatting.bibclean,
            formatting.shellharden,
            formatting.pretty_php,
            gdformat,
            formatting.asmfmt,
            formatting.rustywind,
            formatting.djlint,
            formatting.shfmt.with {
                extra_args = { "-i", "4", "-ci" }, -- change to your dialect
            },
            formatting.cbfmt,
            deno_fmt.with { filetypes = { "markdown" } }, --
            formatting.sql_formatter,
            formatting.prettier,
            -- code_actions  --------------------------------
            code_actions.gitrebase,
            code_actions.proselint,
        },
    }
end
