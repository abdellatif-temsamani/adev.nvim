local events = require "adev-common.utils.events"

---@param key string
---@return integer — Integer id of the created group.
local function _generate_group(key)
    return vim.api.nvim_create_augroup(string.format("adev_%s", key), { clear = true })
end

local lsp_map = {
    lua_ls = { "lua" },
    intelephense = { "php" },
    asm_lsp = { "asm", "vmasm" },
    gopls = { "go", "gomod", "gowork", "gotmpl" },
    astro = { "astro" },
    csharp_ls = { "cs" },
    svelte = { "svelte" },
    pyright = { "python" },
    ruff = { "python" },
    bashls = { "bash", "sh" },
    clangd = { "c", "cpp", "objc", "objcpp", "cuda" },
    html = { "html", "templ" },
    jsonls = { "json", "jsonc" },
    rust_analyzer = { "rust" },
    sqlls = { "sql", "mysql" },
    cssls = { "css", "scss", "less" },
    css_variables = { "css", "scss", "less" },
    prismals = { "prisma" },
    taplo = { "toml" },
    zls = { "zig", "zir" },
    yamlls = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" },
    lemminx = { "xml", "xsd", "xsl", "xslt", "svg" },
    texlab = { "tex", "plaintex", "bib" },
    gleam = { "gleam" },
    glslls = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
    glsl_analyzer = { "glsl", "vert", "tesc", "tese", "frag", "geom", "comp" },
    jdtls = { "java" },
    ts_ls = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },
    cssmodules_ls = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    gdscript = { "gd", "gdscript", "gdscript3" },
    dockerls = { "dockerfile" },
    docker_compose_language_service = { "yaml.docker-compose" },
    cmake = { "cmake" },
    vue = { "vue_ls" },
    emmet_ls = {
        "astro",
        "css",
        "eruby",
        "html",
        "htmlangular",
        "htmldjango",
        "javascriptreact",
        "less",
        "pug",
        "sass",
        "scss",
        "svelte",
        "templ",
        "typescriptreact",
        "vue",
    },
    biome = {
        "astro",
        "css",
        "graphql",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "jsonc",
        "svelte",
        "typescript",
        "typescript.tsx",
        "typescriptreact",
        "vue",
    },
    eslint = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
        "svelte",
        "astro",
        "htmlangular",
    },
    tailwindcss = {
        "aspnetcorerazor",
        "astro",
        "astro-markdown",
        "blade",
        "clojure",
        "django-html",
        "htmldjango",
        "edge",
        "eelixir",
        "elixir",
        "ejs",
        "erb",
        "eruby",
        "gohtml",
        "gohtmltmpl",
        "haml",
        "handlebars",
        "hbs",
        "html",
        "htmlangular",
        "html-eex",
        "heex",
        "jade",
        "leaf",
        "liquid",
        "markdown",
        "mdx",
        "mustache",
        "njk",
        "nunjucks",
        "php",
        "razor",
        "slim",
        "twig",
        "css",
        "less",
        "postcss",
        "sass",
        "scss",
        "stylus",
        "sugarss",
        "javascript",
        "javascriptreact",
        "reason",
        "rescript",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "templ",
    },
}

--- Setup lsp autocmds enabled by the user
---@return nil
local function setup()
    -- TODO: add props to dynamically enable or disable lsps
    for lsp, fts in pairs(lsp_map) do
        vim.api.nvim_create_autocmd({ events.buffer.read_post, events.buffer.new_file }, {
            group = _generate_group(lsp),
            callback = function(args)
                local ft = vim.bo[args.buf].filetype
                if vim.tbl_contains(fts, ft) then
                    vim.schedule(function()
                        vim.lsp.enable(lsp)
                    end)
                end
            end,
        })
    end
end

return {
    lsp_map = lsp_map,
    setup = setup,
    keys = vim.tbl_keys(lsp_map),
}
