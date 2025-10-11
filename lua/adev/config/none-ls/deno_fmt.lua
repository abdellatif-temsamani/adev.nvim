---@module "null-ls.helpers"
local h = require "null-ls.helpers"

---@module "null-ls.methods"
local methods = require "null-ls.methods"

local FORMATTING = methods.internal.FORMATTING

local extensions = {
    markdown = "md",
}

return h.make_builtin({
    name = "deno_fmt",
    meta = {
        url = "https://deno.land/manual/tools/formatter",
        description = "Use [Deno](https://deno.land/) markdown.",
        notes = {
            "`deno fmt` supports formatting markdown.",
        },
        usage = "it's already in use",
    },
    method = FORMATTING,
    filetypes = {
        "markdown",
    },
    generator_opts = {
        command = "deno",
        args = function(params)
            return { "fmt", "-", "--ext", extensions[params.ft] }
        end,
        to_stdin = true,
    },
    factory = h.formatter_factory,
})
