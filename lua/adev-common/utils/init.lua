local Utils = {
    ignored_files = {
        "Cargo.lock",
        "__pycache__/",
        "node_modules/",
        ".git/",
        ".ccls-cache/",
        "build/",
        "target/",
        "dist/",
        "yarn.lock",
        "pnpm-lock.yaml",
        "lazy-lock.json",
    },
    files = require "adev-common.utils.files",
}

---@param msg string
---@param level integer|nil One of the values from |vim.log.levels|.
---@param title? string if not provided defautls to adev.nvim
function Utils.notify(msg, level, title)
    title = title or "adev.nvim"
    if vim.in_fast_event() then
        vim.schedule(function()
            vim.notify(msg, level, { title = "[" .. title .. "]" })
        end)
    else
        vim.notify(msg, level, { title = "[" .. title .. "]" })
    end
end

---@param msg string
---@param title? string if not provided defautls to adev.nvim
function Utils.err_notify(msg, title)
    Utils.notify(msg, vim.log.levels.ERROR, title)
end

--- check two tables and returns true if they're the same
---@param a table
---@param b table
---@return boolean
function Utils.compare_keys(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then
        return false
    end

    for k, v in pairs(a) do
        if b[k] == nil then
            return false
        end

        if type(v) == "table" then
            if type(b[k]) ~= "table" then
                return false
            end

            if not Utils.compare_keys(v, b[k]) then
                return false
            end
        end
    end

    for k in pairs(b) do
        if a[k] == nil then
            return false
        end
    end

    return true
end

--- Restart Neovim after a delay
---@param delay number? Delay in milliseconds `default = 2000`
function Utils.restart_neovim(delay)
    delay = delay or 2000

    Utils.notify("restarting neovim in " .. delay .. "ms", vim.log.levels.TRACE)
    vim.defer_fn(function()
        if vim.fn.has "nvim-0.12.0" == 1 then
            vim.cmd [[ restart ]]
        else
            vim.cmd [[ qa! ]]
        end
    end, delay)
end

return Utils
