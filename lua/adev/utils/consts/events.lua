local events = {
    file = { "BufRead", "BufNewFile" },
    pre = { "BufReadPre", "BufNewFile" },
    lsp = { "LspAttach" },
    insert = { "InsertEnter" },
    cmd = { "CmdlineEnter" },
}

---Merges selected event categories into one unique, flattened list of event names.
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

return events
