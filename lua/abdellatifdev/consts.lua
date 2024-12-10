local ignored_files = {
    "Cargo.lock", "__pycache__", "node_modules", ".git",
    "build", "dist", "yarn.lock", "pnpm-lock.yaml", "lazy-lock.json"
}

local file_event = { "BufRead", "BufNewFile" }
local pre_file_event = { "BufReadPre" }
local lsp_event = { "LspAttach" }
local insert_event = { "InsertEnter" }
local cmd_event = { "CmdlineEnter" }

return {
    ignored_files = ignored_files,
    file_event = file_event,
    lsp_event = lsp_event,
    insert_event = insert_event,
    cmd_event = cmd_event,
    pre_file_event = pre_file_event,
}
