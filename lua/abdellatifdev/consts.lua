---List of file and directory patterns to be ignored by tools (e.g., search, linting).
---@type string[]
local ignored_files = {
    "Cargo.lock", "__pycache__/", "node_modules/", ".git/",
    ".ccls-cache/", "build/", "target/", "dist/",
    "yarn.lock", "pnpm-lock.yaml", "lazy-lock.json"
}

---Grouped autocommand event categories used for plugin setups or internal triggers.
---@class EventCategories
---@field file string[] Events related to reading or opening a file
---@field pre string[] Events triggered before reading or opening a file
---@field lsp string[] Events related to attaching the LSP client
---@field insert string[] Events triggered on insert mode entry
---@field cmd string[] Events triggered when entering the command line
local events = {
    file = { "BufRead", "BufNewFile" },
    pre = { "BufReadPre", "BufNewFile" },
    lsp = { "LspAttach" },
    insert = { "InsertEnter" },
    cmd = { "CmdlineEnter" },
}

---Merges selected event categories into one unique, flattened list of event names.
---
---Useful when configuring autocommands or plugin triggers with multiple categories.
---
---@param selected_keys string[] List of keys from the `events` table to merge.
---@return string[] Unique list of all autocommand event names.
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

---Module exports.
---@type { ignored_files: string[], events: EventCategories }
return {
    ignored_files = ignored_files,
    events = events,
}
