local M = {}

local function cleanup_user_keys(merged, defaults)
    for key in pairs(merged) do
        if defaults[key] == nil then
            merged[key] = nil
        elseif type(merged[key]) == "table" and type(defaults[key]) == "table" then
            cleanup_user_keys(merged[key], defaults[key])
        end
    end
end

function M.merge_configs(defaults, user_config)
    local merged = vim.tbl_deep_extend("force", defaults, user_config or {})
    cleanup_user_keys(merged, defaults)
    return merged
end

return M
