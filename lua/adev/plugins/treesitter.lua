local events = require "adev-common.utils.events"
local plugin = require "adev-common.plugin"

return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        branch = "main",
        dependencies = {
            {
                "nvim-treesitter/nvim-treesitter-context",
                event = plugin.file_events(),
                opts = {
                    enable = true,
                    max_lines = 2,
                    zindex = 20,
                },
            },
            {
                "windwp/nvim-ts-autotag",

                event = plugin.file_events(),
                opts = {
                    per_filetype = {
                        ["blade"] = {
                            enable_close = true,
                            enable_rename = true,
                            enable_close_on_slash = false,
                        },
                        ["xml"] = {
                            enable_close = true,
                            enable_rename = true,
                            enable_close_on_slash = false,
                        },
                    },
                },
            },
        },
        build = ":TSUpdate",
        opts = {
            ensure_installed = "all",
        },
        config = function(_, opts)
            local treesitter = require "nvim-treesitter"
            treesitter.install(opts.ensure_installed)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function()
                    local lang = vim.bo.filetype
                    if not lang or lang == "" then
                        return
                    end

                    local ok = pcall(vim.treesitter.start)
                    if not ok then
                        return
                    end

                    -- vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                    -- vim.wo.foldmethod = "expr"
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
}
