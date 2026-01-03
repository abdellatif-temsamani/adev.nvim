local update_manager = require "adev.update_manager"
local utils = require "adev-common.utils"

local M = {}

--- Parse the changelog content and extract the section for a specific version
---@param content string The full changelog content
---@param version string The version to extract (e.g., "2.0.0")
---@return string|nil The changelog section for the version, or nil if not found
local function extract_version_section(content, version)
    -- Remove 'v' prefix if present in version for matching
    local clean_version = version:gsub("^v", "")

    -- Pattern to match version headers like "## [2.0.0] - 2025-10-30"
    local version_pattern = "%[" .. clean_version:gsub("%-", "%%-") .. "%]"

    local lines = vim.split(content, "\n")
    local start_line = nil
    local end_line = nil

    -- Find the start of the version section
    for i, line in ipairs(lines) do
        if line:match("^## " .. version_pattern) then
            start_line = i
            break
        end
    end

    if not start_line then
        return nil
    end

    -- Find the end of the version section (next version header or end of file)
    for i = start_line + 1, #lines do
        if lines[i]:match "^## %[" then
            end_line = i - 1
            break
        end
    end

    end_line = end_line or #lines

    -- Extract the section
    local section_lines = {}
    for i = start_line, end_line do
        table.insert(section_lines, lines[i])
    end

    return table.concat(section_lines, "\n")
end

--- Get the changelog content for a specific version
---@param version string|nil The version to get changelog for (nil for current version)
---@return string|nil The changelog content, or nil if error
local function get_version_changelog(version)
    -- Get version (use current if not specified)
    if not version then
        local success, current_version = pcall(update_manager.get_version)
        if not success or not current_version or current_version == "" then
            utils.err_notify "Could not determine current version"
            return nil
        end
        version = current_version
    end

    -- Read the changelog file
    local changelog_path = utils.adev_path .. "/CHANGELOG.md"
    local file = io.open(changelog_path, "r")
    if not file then
        utils.err_notify "Could not open CHANGELOG.md"
        return nil
    end

    local content = file:read "*all"
    file:close()

    -- Extract the section for the specified version
    local version_section = extract_version_section(content, version)
    if not version_section then
        utils.err_notify("Could not find changelog section for version " .. version)
        return nil
    end

    return version_section
end

--- Show the changelog in a popup window
---@param args table|nil Command arguments from nvim_create_user_command
function M.show_changelog(args)
    local version = nil
    if args and args.args and args.args ~= "" then
        version = args.args
    end

    local changelog_content = get_version_changelog(version)
    if not changelog_content then
        return
    end

    -- Check if Snacks is available, fallback to simple display
    if not Snacks or not Snacks.win then
        -- Fallback: print to messages or open in a new buffer
        print "=== Adev.nvim Changelog ==="
        print(changelog_content)
        return
    end

    -- Get version for title (use specified version or current)
    local version_title = version
    if not version_title then
        local success, current_version = pcall(update_manager.get_version)
        version_title = success and current_version or "Unknown"
    end

    -- Create a temporary buffer with the changelog content
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(changelog_content, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Set buffer options using modern API
    vim.bo[buf].filetype = "markdown"
    vim.bo[buf].modifiable = false
    vim.bo[buf].readonly = true

    -- Get border style safely
    local border = "single"
    if _G.Adev and _G.Adev.ui and _G.Adev.ui.border then
        border = _G.Adev.ui.border
    end

    -- Show in a Snacks window
    Snacks.win {
        buf = buf,
        title = "Adev.nvim Changelog - " .. version_title,
        border = border,
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

--- Get the changelog content for a specific version (for testing/debugging)
---@param version string|nil The version to get changelog for (nil for current version)
---@return string|nil The changelog content, or nil if error
function M.get_changelog(version)
    return get_version_changelog(version)
end

--- Get list of available versions from git tags
---@return string[]|nil List of available versions, or nil if error
function M.get_available_versions()
    local git_cmd = { _G.Adev.git, "tag", "--list", "--sort=-version:refname" }
    local result = vim.system(git_cmd, {
        cwd = utils.adev_path,
        text = true,
    }):wait()

    if result.code ~= 0 then
        utils.err_notify "Failed to get git tags"
        return nil
    end

    local versions = {}
    for line in result.stdout:gmatch "[^\r\n]+" do
        if line ~= "" then
            table.insert(versions, line)
        end
    end

    return versions
end

--- Show available versions
function M.list_versions()
    local versions = M.get_available_versions()
    if not versions then
        return
    end

    print "Available versions:"
    for _, version in ipairs(versions) do
        print("  " .. version)
    end
    print "\nUsage: :ADChangelog [version]"
    print "Example: :ADChangelog v1.5.0"
end

return M
