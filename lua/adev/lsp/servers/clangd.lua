return require("adev.lsp.servers.configure").server("clangd", {
    cmd = {
        "clangd",
        "--compile-commands-dir=build",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--all-scopes-completion",
        "--header-insertion=iwyu",
        "--header-insertion-decorators",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
    },
})
