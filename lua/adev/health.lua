local check_version = function()
  vim.health.start('Neovim Version')
  
  local version = vim.version()
  local verstr = tostring(version)
  
  -- Check if vim.version.ge exists (indicates newer Neovim)
  if not vim.version.ge then
    vim.health.error(string.format("Neovim version too old: '%s'. Missing vim.version.ge function.", verstr))
    vim.health.info("Please upgrade to Neovim 0.11.0 or later")
    return false
  end

  -- Check minimum required version
  local min_version = { 0, 11, 0 }
  if vim.version.ge(version, min_version) then
    vim.health.ok(string.format("Neovim version: %s ✓", verstr))
    return true
  else
    vim.health.error(string.format("Neovim version: %s (minimum required: 0.11.0)", verstr))
    vim.health.info("Please upgrade to Neovim 0.11.0 or later for full compatibility")
    return false
  end
end

local get_executable_version = function(exe, version_flag)
  version_flag = version_flag or '--version'
  local handle = io.popen(exe .. ' ' .. version_flag .. ' 2>/dev/null')
  if not handle then return nil end
  
  local result = handle:read('*l')
  handle:close()
  return result
end

local check_required_executables = function()
  vim.health.start('Required Executables')
  
  local required = {
    { name = 'git', desc = 'Version control system', critical = true },
    { name = 'make', desc = 'Build automation tool', critical = true },
    { name = 'unzip', desc = 'Archive extraction utility', critical = true },
  }
  
  local all_found = true
  for _, exe in ipairs(required) do
    local is_executable = vim.fn.executable(exe.name) == 1
    if is_executable then
      local version = get_executable_version(exe.name)
      local version_info = version and string.format(" (%s)", version:match('[%d%.]+[%w%-]*') or 'unknown') or ''
      vim.health.ok(string.format("%s: found%s", exe.name, version_info))
    else
      if exe.critical then
        vim.health.error(string.format("%s: not found - %s (REQUIRED)", exe.name, exe.desc))
        all_found = false
      else
        vim.health.warn(string.format("%s: not found - %s", exe.name, exe.desc))
      end
    end
  end
  
  return all_found
end

local check_optional_executables = function()
  vim.health.start('Optional Executables')
  
  local optional = {
    { name = 'rg', desc = 'Fast text search (ripgrep)', install = 'cargo install ripgrep' },
    { name = 'lazygit', desc = 'Terminal UI for git', install = 'go install github.com/jesseduffield/lazygit@latest' },
    { name = 'gh', desc = 'GitHub CLI', install = 'https://cli.github.com/manual/installation' },
    { name = 'gh-dash', desc = 'GitHub dashboard', install = 'go install github.com/dlvhdr/gh-dash@latest' },
    { name = 'fd', desc = 'Fast file finder', install = 'cargo install fd-find' },
    { name = 'bat', desc = 'Better cat with syntax highlighting', install = 'cargo install bat' },
  }
  
  for _, exe in ipairs(optional) do
    local is_executable = vim.fn.executable(exe.name) == 1
    if is_executable then
      local version = get_executable_version(exe.name)
      local version_info = version and string.format(" (%s)", version:match('[%d%.]+[%w%-]*') or 'unknown') or ''
      vim.health.ok(string.format("%s: found%s", exe.name, version_info))
    else
      vim.health.warn(string.format("%s: not found - %s", exe.name, exe.desc))
      if exe.install then
        vim.health.info(string.format("Install with: %s", exe.install))
      end
    end
  end
end

local check_lua_modules = function()
  vim.health.start('Local adev Modules')
  
  local modules = {
    { name = 'adev.init', desc = 'Main adev module', critical = true },
    { name = 'adev.consts', desc = 'Constants and configuration', critical = true },
    { name = 'adev.utils', desc = 'Utility functions', critical = true },
    { name = 'adev.config.mini', desc = 'Mini.nvim configuration', critical = false },
    { name = 'adev.config.treesitter', desc = 'Treesitter configuration', critical = true },
    { name = 'adev.config.none-ls.init', desc = 'None-ls configuration', critical = false },
  }
  
  local loaded_count = 0
  local critical_count = 0
  local critical_loaded = 0
  
  for _, mod in ipairs(modules) do
    if mod.critical then
      critical_count = critical_count + 1
    end
    
    local ok, _ = pcall(require, mod.name)
    if ok then
      loaded_count = loaded_count + 1
      if mod.critical then
        critical_loaded = critical_loaded + 1
      end
      vim.health.ok(string.format("%s: loaded ✓", mod.name))
    else
      if mod.critical then
        vim.health.error(string.format("%s: not found - %s (REQUIRED)", mod.name, mod.desc))
      else
        vim.health.warn(string.format("%s: not found - %s (optional)", mod.name, mod.desc))
      end
    end
  end
  
  -- Summary
  vim.health.info(string.format("Total modules loaded: %d/%d", loaded_count, #modules))
  if critical_loaded == critical_count then
    vim.health.ok(string.format("All critical modules loaded (%d/%d) ✓", critical_loaded, critical_count))
  else
    vim.health.error(string.format("Missing critical modules (%d/%d)", critical_loaded, critical_count))
  end
end

local check_nerd_font = function()
  vim.health.start('Nerd Font Support')
  
  -- Test various Nerd Font icons
  local nerd_font_tests = {
    { icon = '\u{f07c}', name = 'Folder icon', category = 'File icons' },
    { icon = '\u{f15b}', name = 'File icon', category = 'File icons' },
    { icon = '\u{e7a2}', name = 'Git branch', category = 'Git icons' },
    { icon = '\u{f126}', name = 'Code icon', category = 'Development icons' },
    { icon = '\u{f0e7}', name = 'Lightning bolt', category = 'UI icons' },
    { icon = '\u{f188}', name = 'Bug icon', category = 'Development icons' },
    { icon = '\u{f0c9}', name = 'Menu icon', category = 'UI icons' },
    { icon = '\u{f00c}', name = 'Check mark', category = 'Status icons' },
  }
  
  -- Check terminal capabilities
  local term = vim.env.TERM or 'unknown'
  vim.health.info(string.format("Terminal: %s", term))
  
  -- Check for common terminal emulators that support Nerd Fonts
  local terminal_app = vim.env.TERM_PROGRAM or vim.env.TERMINAL_EMULATOR or 'unknown'
  if terminal_app ~= 'unknown' then
    vim.health.info(string.format("Terminal app: %s", terminal_app))
  end
  
  -- Check color support
  local colorterm = vim.env.COLORTERM
  if colorterm then
    vim.health.ok(string.format("Color support: %s ✓", colorterm))
  else
    vim.health.warn("COLORTERM not set - may have limited color support")
  end
  
  -- Display test icons with explanations
  vim.health.info("Nerd Font icon test (check if these display correctly):")
  for _, test in ipairs(nerd_font_tests) do
    vim.health.info(string.format("  %s  %s (%s)", test.icon, test.name, test.category))
  end
  
  -- Font recommendations
  vim.health.info("")
  vim.health.info("If icons don't display correctly, install a Nerd Font:")
  vim.health.info("  • AnonymicePro Nerd Font Mono (recommended)")
  vim.health.info("  • JetBrains Mono Nerd Font")
  vim.health.info("  • Fira Code Nerd Font")
  vim.health.info("  • Hack Nerd Font")
  vim.health.info("  • Download from: https://www.nerdfonts.com/")
  
  -- Check if we're in a GUI or terminal
  if vim.fn.has('gui_running') == 1 then
    vim.health.info("Running in GUI - font should be configurable in settings")
  else
    vim.health.info("Running in terminal - configure font in terminal emulator")
  end
end

local check_system_info = function()
  vim.health.start('System Information')
  
  local uv = vim.uv or vim.loop
  local sysinfo = uv.os_uname()
  
  vim.health.info(string.format("OS: %s %s", sysinfo.sysname, sysinfo.release))
  vim.health.info(string.format("Architecture: %s", sysinfo.machine))
  
  -- Check shell
  local shell = vim.env.SHELL or 'unknown'
  vim.health.info(string.format("Shell: %s", shell:match('([^/]+)$') or shell))
  
  -- Check if running in tmux/screen
  if vim.env.TMUX then
    vim.health.info("Running inside tmux ✓")
  elseif vim.env.STY then
    vim.health.info("Running inside screen ✓")
  end
end

local check_configuration = function()
  vim.health.start('Configuration')
  
  -- Check if adev module can be loaded
  local ok, adev = pcall(require, 'adev')
  if ok then
    vim.health.ok("adev module: loaded ✓")
    
    -- Check if setup was called
    if adev.setup then
      vim.health.ok("adev.setup: available ✓")
    else
      vim.health.warn("adev.setup: not found - make sure to call require('adev').setup()")
    end
  else
    vim.health.error("adev module: failed to load")
    vim.health.info("Make sure adev.nvim is properly installed")
  end
  
  -- Check config directory
  local config_dir = vim.fn.stdpath('config')
  if vim.fn.isdirectory(config_dir) == 1 then
    vim.health.ok(string.format("Config directory: %s ✓", config_dir))
  else
    vim.health.error(string.format("Config directory not found: %s", config_dir))
  end
end

return {
  check = function()
    vim.health.start('adev.nvim Health Check')
    vim.health.info('Checking adev.nvim installation and dependencies...')
    vim.health.info('NOTE: Not every warning requires immediate action')
    
    -- Run all checks
    local version_ok = check_version()
    check_system_info()
    check_nerd_font()
    
    local executables_ok = check_required_executables()
    check_optional_executables()
    check_lua_modules()
    check_configuration()
    
    -- Summary
    vim.health.start('Summary')
    if version_ok and executables_ok then
      vim.health.ok('adev.nvim should work correctly ✓')
    else
      vim.health.warn('Some issues found - check the details above')
      vim.health.info('Fix critical errors first, warnings are optional')
    end
  end,
}
