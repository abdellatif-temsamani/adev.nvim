local M = {}

local function ok(msg)
    vim.health.ok(msg)
end

local function warn(msg, advice)
    vim.health.warn(msg, advice)
end

local function err(msg, advice)
    vim.health.error(msg, advice)
end

local function info(msg)
    vim.health.info(msg)
end

local function has(mod)
    local ok_mod, value = pcall(require, mod)
    return ok_mod, value
end

function M.check()
    vim.health.start "adev-files"

    local ok_cfg, cfg_mod = has "adev-files"
    if not ok_cfg then
        err("adev-files module failed to load", { "Check lua/adev-files/init.lua for errors" })
        return
    end
    ok "adev-files module loaded"

    local config = type(cfg_mod.get_config) == "function" and cfg_mod.get_config() or cfg_mod.config
    if type(config) == "table" then
        ok "configuration available"
        info(string.format("replace_netrw: %s", tostring(config.replace_netrw)))
        local open_files = config.open_files or {}
        info(string.format("open_files.enabled: %s", tostring(open_files.enabled)))
        info(string.format("open_files.method: %s", tostring(open_files.method or "edit")))
    else
        warn("configuration not available", { "Call require('adev-files').setup()" })
    end

    local commands = vim.api.nvim_get_commands {}
    if commands.AdevFiles then
        ok ":AdevFiles command registered"
    else
        warn(":AdevFiles command not registered", { "Call require('adev-files').setup()" })
    end

    local modules = {
        "adev-files.file_manager",
        "adev-files.events",
        "adev-files.sync.view",
        "adev-files.sync.plan",
        "adev-files.sync.apply",
        "adev-files.git",
        "adev-files.help",
    }
    for _, mod in ipairs(modules) do
        local ok_mod = has(mod)
        if ok_mod then
            ok(mod .. " loaded")
        else
            err(mod .. " failed to load")
        end
    end

    vim.health.start "adev-files dependencies"
    if vim.fn.executable "git" == 1 then
        local git = (Adev and Adev.git) or "git"
        if vim.fn.executable(git) == 1 then
            ok("git executable: " .. git)
        else
            warn("configured git executable not found: " .. tostring(git), {
                "Set Adev.git to a valid executable",
            })
        end
    else
        warn("git executable not found", { "Git status indicators will be unavailable" })
    end

    if vim.fn.executable "fd" == 1 then
        ok "fd found (optional)"
    else
        info "fd not found (optional)"
    end
    if vim.fn.executable "rg" == 1 then
        ok "rg found (optional)"
    else
        info "rg not found (optional)"
    end

    vim.health.start "adev-files runtime checks"
    local ok_state, state = has "adev-files.state"
    local ok_list, listing = has "adev-files.file_manager.listing"
    if ok_state and ok_list and type(listing.build_lines) == "function" then
        local tmp = vim.fn.tempname()
        vim.fn.mkdir(tmp, "p")
        local lines, list_err = listing.build_lines(tmp)
        vim.fn.delete(tmp, "d")
        if type(lines) == "table" then
            ok "directory listing smoke test passed"
        else
            err("directory listing smoke test failed: " .. tostring(list_err))
        end
    else
        warn("skipped listing smoke test", { "Required modules unavailable" })
    end

    local ok_git, git_mod = has "adev-files.git"
    if ok_git and type(git_mod.fetch_status) == "function" then
        ok "git status API available"
    else
        warn "git status API unavailable"
    end
end

return M
