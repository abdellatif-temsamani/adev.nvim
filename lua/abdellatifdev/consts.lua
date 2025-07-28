local ignored_files = {
    "Cargo.lock", "__pycache__/", "node_modules/", ".git/",
    ".ccls-cache/", "build/", "node_modules/", "target/",
    "dist/", "yarn.lock", "pnpm-lock.yaml", "lazy-lock.json"
}

local events = {
    file = { "BufRead", "BufNewFile" },
    pre = { "BufReadPre", "BufNewFile" },
    lsp = { "LspAttach" },
    insert = { "InsertEnter" },
    cmd = { "CmdlineEnter" },
}

--- Merges selected event categories into one unique list
---@param selected_keys string[] @List of keys from the `events` table
---@return string[]
function events:merge(selected_keys)
    local result = {}
    local seen = {}

    for _, key in ipairs(selected_keys) do
        if not events[key] then
            error(("Invalid event key: %s"):format(key))
        end
        local list = self[key]
        if list then
            for _, event in ipairs(list) do
                if not seen[event] then
                    seen[event] = true
                    table.insert(result, event)
                end
            end
        end
    end

    return result
end

return {
    ignored_files = ignored_files,
    events = events,
}
