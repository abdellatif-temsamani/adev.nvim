local M = {}

function M.check()
    vim.health.start "adev.nvim"

    if vim.version.ge and vim.version.ge(vim.version(), { 0, 11, 0 }) then
        vim.health.ok(string.format("Neovim version: %s", tostring(vim.version())))
    else
        vim.health.error(
            string.format("Neovim version %s is too old", tostring(vim.version())),
            { "Upgrade to Neovim 0.11.0 or later" }
        )
    end

    local required = { "git", "make", "unzip" }
    for _, exe in ipairs(required) do
        if vim.fn.executable(exe) == 1 then
            vim.health.ok(exe .. " found")
        else
            vim.health.warn(exe .. " not found")
        end
    end

    local ok_adev = pcall(require, "adev")
    if ok_adev then
        vim.health.ok "adev module loaded"
    else
        vim.health.error "adev module failed to load"
    end

    local ok_files_health, files_health = pcall(require, "adev-files.health")
    if ok_files_health and type(files_health.check) == "function" then
        files_health.check()
    else
        vim.health.warn "adev-files health module not found"
    end
end

return M
