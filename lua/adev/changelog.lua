local git = require "adev-common.git"
local ui = require "adev-common.ui"
local utils = require "adev-common.utils"

local M = {}

local function extract_version_section(content, version)
    local clean_version = version:gsub("^v", "")
    local version_pattern = "%[" .. clean_version:gsub("%-", "%%-") .. "%]"
    local lines = vim.split(content, "\n")

    local start_idx
    for i, line in ipairs(lines) do
        if line:match("^## " .. version_pattern) then
            start_idx = i
            break
        end
    end
    if not start_idx then
        return nil
    end

    local end_idx = #lines
    for i = start_idx + 1, #lines do
        if lines[i]:match "^## %[" then
            end_idx = i - 1
            break
        end
    end

    return table.concat(vim.list_slice(lines, start_idx, end_idx), "\n")
end

function M.get_changelog(version)
    if not version or version == "" then
        version = git.get_version()
        if not version or version == "" then
            utils.err_notify "Could not determine current version"
            return nil
        end
    end

    local content = table.concat(vim.fn.readfile(utils.files:get_config_file "/CHANGELOG.md"), "\n")
    if content == "" then
        utils.err_notify "Could not open CHANGELOG.md"
        return nil
    end

    local section = extract_version_section(content, version)
    if not section then
        utils.err_notify("Could not find changelog section for version " .. version)
        return nil
    end
    return section
end

function M.show_changelog(args)
    local changelog = M.get_changelog(args and args.args)
    if not changelog then
        return
    end

    if not Snacks or not Snacks.win then
        print "=== Adev.nvim Changelog ==="
        print(changelog)
        return
    end

    local buf = utils.buffers.create(vim.split(changelog, "\n"), {
        listed = false,
        scratch = true,
        bo = {
            modifiable = false,
            filetype = "markdown",
            bufhidden = "wipe",
        },
    })

    ui.window.floating_window {
        buf = buf,
        title = "Adev.nvim Changelog - " .. (git.get_version() or "Unknown"),
        width = 0.8,
        height = 0.8,
        wo = {
            spell = false,
            wrap = true,
            signcolumn = "no",
            statuscolumn = " ",
            conceallevel = 2,
        },
    }
end

function M.get_available_versions()
    return git.get_available_versions()
end

function M.get_info()
    local version = git.get_version()
    if not version then
        return
    end
    local message = {
        string.format("- `Version`: %s", vim.inspect(version)),
        "- `Author`: Abdellatif Dev",
        "- `URL`: [github](https://github.com/abdellatif-temsamani/adev.nvim/)",
    }

    local buf = utils.buffers.create(message, {
        listed = false,
        scratch = true,
        bo = {
            modifiable = false,
            filetype = "markdown",
            bufhidden = "wipe",
        },
    })

    ui.window.floating_window {
        buf = buf,
        title = "Adev.nvim Info",
        width = 0.3,
        height = 0.3,
        wo = {
            spell = false,
            wrap = true,
            signcolumn = "no",
            statuscolumn = " ",
            conceallevel = 2,
        },
    }
end

return M
