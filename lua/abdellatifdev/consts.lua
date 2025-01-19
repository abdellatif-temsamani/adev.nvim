local ignored_files = {
    "Cargo.lock", "__pycache__", "node_modules", ".git",
    "/.ccls-cache", "/build/", "/node_modules", "/target",
     "dist/", "yarn.lock", "pnpm-lock.yaml", "lazy-lock.json"
}


local events = {
    file = { "BufRead", "BufNewFile" },
    pre = { "BufReadPre" },
    lsp = { "LspAttach" },
    insert = { "InsertEnter" },
    cmd = { "CmdlineEnter" },

}

return {
    ignored_files = ignored_files,
    events = events,
}
