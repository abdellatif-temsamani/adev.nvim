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
    adev_path = vim.fn.stdpath "config",
}

--- @param msg string
--- @param level integer|nil One of the values from |vim.log.levels|.
function Utils.notify(msg, level)
    vim.notify(msg, level, { title = "adev.nvim" })
end

--- @param msg string
function Utils.err_notify(msg)
    Utils.notify(msg, vim.log.levels.ERROR)
end

function Utils.disable_movement(buf)
    local map = vim.api.nvim_buf_set_keymap
    local opts = { noremap = true, silent = true }

    map(buf, "n", "h", "<Nop>", opts)
    map(buf, "n", "j", "<Nop>", opts)
    map(buf, "n", "k", "<Nop>", opts)
    map(buf, "n", "l", "<Nop>", opts)
    map(buf, "n", "<Up>", "<Nop>", opts)
    map(buf, "n", "<Down>", "<Nop>", opts)
    map(buf, "n", "<Left>", "<Nop>", opts)
    map(buf, "n", "<Right>", "<Nop>", opts)
end

--- @param a table
--- @param b table
--- @return boolean
function Utils.compare_keys(a, b)
    for k in pairs(a) do
        if b[k] == nil then
            return false
        end
    end
    for k in pairs(b) do
        if a[k] == nil then
            return false
        end
    end
    return true
end

---@param path string
---@param content string[]
function Utils.write_file(path, content)
    local opts_file = assert(io.open(path, "w"), "Failed to open " .. path)
    opts_file:write(table.concat(content))
    opts_file:close()
end

return Utils
