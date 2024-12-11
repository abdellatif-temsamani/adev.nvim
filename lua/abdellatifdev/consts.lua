local ignored_files = {
    "Cargo.lock", "__pycache__", "node_modules", ".git",
    "build", "dist", "yarn.lock", "pnpm-lock.yaml", "lazy-lock.json"
}


local event = {
    file = { "BufRead", "BufNewFile" },
    pre = { "BufReadPre" },
    lsp = { "LspAttach" },
    insert = { "InsertEnter" },
    cmd = { "CmdlineEnter" },

}

return {
    ignored_files = ignored_files,
    file_event = event.file,
    lsp_event = event.lsp,
    insert_event = event.insert,
    cmd_event = event.cmd,
    pre_file_event = event.pre,
}
