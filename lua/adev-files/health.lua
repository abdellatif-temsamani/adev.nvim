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
    if type(vim.system) == "function" then
        ok "vim.system available"
    else
        err("vim.system unavailable", { "adev-files needs Neovim 0.10+ for git status" })
    end
    local git = (Adev and Adev.git) or "git"
    if vim.fn.executable(git) == 1 then
        ok("git executable: " .. git)
    else
        warn("git executable not found: " .. tostring(git), {
            "Set Adev.git to a valid executable on PATH",
        })
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
        local ok_mkdir, mkdir_err = pcall(vim.fn.mkdir, tmp, "p")
        if not ok_mkdir or vim.fn.isdirectory(tmp) ~= 1 then
            err("cannot create temp directory for listing smoke test: " .. tostring(mkdir_err))
        else
            local ok_listing, lines, list_err = pcall(listing.build_lines, tmp)
            local ok_delete, delete_result = pcall(vim.fn.delete, tmp, "rf")
            if not ok_delete or delete_result ~= 0 then
                warn("could not clean up temp directory: " .. tmp, {
                    "Remove it manually; adev-files only uses it for a smoke test",
                })
            end
            if not ok_listing then
                err("directory listing smoke test raised: " .. tostring(lines))
            elseif type(lines) == "table" then
                ok "directory listing smoke test passed"
            else
                err("directory listing smoke test failed: " .. tostring(list_err))
            end
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
