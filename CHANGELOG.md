# Changelog

All notable changes to Adev.nvim (the over-engineered nvim distro) will be
documented in this file.

This changelog is automatically generated using
[git-cliff](https://git-cliff.org).

## About

Adev.nvim is an over-engineered Neovim distribution maintained by Abdellatif
Dev, featuring a modern and efficient development environment with carefully
curated plugins and settings.

## [2.0.3] - 2026-01-11

### 🚀 Features

- Add feature flags system for experimental features (#5)

### 🐛 Bug Fixes

- Improve remote tag fetching and async handling

### 🚜 Refactor

- Improve onboarding module structure
- Consolidate update_manager into single module
- Extract git utilities to common module
- _(utils)_ Restart_nvim to nvim
- Unify window and buffer creation API
- _(utils)_ Restart neovim take 2000ms instead of 1500ms
- _(blink)_ Start on CmdEnter
- Consolidate types and improve error handling

### ⚙️ Miscellaneous Tasks

- Fix dupe @return
- _(coderabbit)_ Added .coderabbit.yaml

## [2.0.2] - 2026-01-09

### 🚀 Features

- Add build command for Catppuccin theme
- Update treesitter
- Adev-files
- _(core)_ Spliting to adev, adev-common
- _(adev-files)_ List files
- Add build command for Catppuccin theme
- Update treesitter
- Adev-files
- _(core)_ Spliting to adev, adev-common
- _(adev-files)_ List files
- Add feature flags system

### 🐛 Bug Fixes

- _(treesitter)_ Add ipkg to ignore_install list
- Remove those annoying arg auto fill snippets
- _(blink)_ Cmdline completions
- _(onboarding)_ If init.lua exist but init-opts.lua not found edge case
- _(core)_ Fix onboarding
- Get_dirname
- _(blink)_ Completions
- Spelling
- _(treesitter)_ Add ipkg to ignore_install list
- Treesitter
- Remove those annoying arg auto fill snippets
- _(blink)_ Cmdline completions
- _(onboarding)_ If init.lua exist but init-opts.lua not found edge case
- _(core)_ Fix onboarding
- Get_dirname
- _(blink)_ Completions
- Spelling
- Refactor config merging to properly handle user-only keys
- _(typo)_ Lua/adev-common/utils/files.lua
- Docs
- _(adev-files)_ Expand paths consistently before file operations

### 🚜 Refactor

- _(onboarding)_ ADConfig hot-reloads nvim
- _(plugins)_ Changing plugins configs
- _(mini)_ Move to standalone mini.nvim plugins
- _(adev-files)_ Common-utils
- Simplify mini plugin spec nesting and update UI structure
- Improve neovim config utilities and plugin settings
- _(adev-files)_ Refactor list files to open in a floating window
- _(adev-files)_ List files improve highlighting
- Improve input UI signature and centralize file operations
- Improve code structure and error handling
- _(onboarding)_ ADConfig hot-reloads nvim
- _(plugins)_ Changing plugins configs
- _(mini)_ Move to standalone mini.nvim plugins
- _(adev-files)_ Common-utils
- Simplify mini plugin spec nesting and update UI structure
- Improve neovim config utilities and plugin settings
- _(adev-files)_ Refactor list files to open in a floating window
- _(adev-files)_ List files improve highlighting
- Improve input UI signature and centralize file operations
- Improve code structure and error handling
- Restructure adev-files actions

### 📚 Documentation

- Improve personal statement supporting Palestinian human rights
- Update TODO.md with custom file management UI
- Update TODO.md with custom file management UI
- Update documentation with feature flags info
- Mention :ADConfig command for modifying flags

### 🎨 Styling

- Fix lua doc comment syntax

### ⚙️ Miscellaneous Tasks

- _(laravel)_ Switch to laravel
- _(adev-files)_ List files help index
- Add project-specific git attributes for neovim config
- _(laravel)_ Switch to laravel
- _(adev-files)_ List files help index
- Add project-specific git attributes for neovim config

## [2.0.1] - 2025-12-23

### 🚀 Features

- Lazy laoding
- Nvim-cmp -> blink-cmp
- Mini.nvim && cleaning plugins
- Config to distro
- _(snacks)_ Add image support
- _(lsp)_ Diagonistic vertual line [expermental]
- _(config)_ Mv config to lua/abdellatifdev/config
- _(git-worktree)_ [**breaking**] Rm plugins
- _(health)_ Healthcheck adev
- _(blink-cmp)_ Conventional-commits
- _(blink-cmp)_ Ghostline cmdline
- _(noice)_ Override defaults
- _(lsp)_ Tailwindcss config
- _(blink.nvim)_ [**breaking**] Removing providers
- _(cmp)_ [**breaking**] Blink-cmp -> nvim-cmp
- Godot linting
- Gdformat use spaces
- Auto check for update
- _(autocmd)_ Gdscript space
- _(cmp)_ Back to blink.cmp v1.3.1
- _(lua)_ Vim highlight as builtin
- [**breaking**] Lua_ls hints
- More info
- New utils function
- Opts "git"
- Opts "colorscheme"
- _(blink-cmp)_ Calc source
- _(null-ls)_ Added stylua
- _(new-plugin)_ [**breaking**] Augment
- _(set)_ More options
- Add treesitter auto-start configuration and update project release name
- Temp implementation of ADConfig

### 🐛 Bug Fixes

- Readme
- Snacks
- Lsp keymaps
- _(blink.cmp)_ Temp fix
- _(theme)_ Align with telescope and snacks
- _(lualine)_ Winbar now displays "Adev.nvim" instead of "abdellatif dev"
- _(blink.cmp)_ Downgrade to "v1.3.1"
- _(crates.nvim)_ Add event for lazy loading
- _(treesitter)_ Plugin event
- _(telescope)_ Border style
- _(laravel)_ Missing deps
- Better notifications
- _(laravel)_ [**breaking**] Fix commands
- [**breaking**] Cmp
- Sets config
- _(blink.cmp)_ Config
- Version
- Check update
- _(laravel)_ Fix lazyloading
- Lazy loading
- Lazyloading
- Luadocs
- Queries
- _(comments)_ Lazyloading conditions
- _(mason)_ Lazyloading
- _(mason)_ Plugin not loading
- [**breaking**] Lazy loading condition
- _(mason-lspconfig)_ Origin
- Config
- _(options)_ Border = 'single'
- _(plugins)_ Event loading
- _(treesitter)_ Not loading
- _(plugins)_ Lazy loading conditions
- _(gitsigns)_ Lazyloading
- Add assertion for LSP defaults in lsp.lua
- Treesitter config

### 🚜 Refactor

- _(notification)_ Changes notification handling
- _(theme)_ Optimize opts
- _(theme)_ Optimize config
- _(plugins)_ Lazy = true as default value
- _(comments)_ Change config
- _(ui)_ Border styles
- _(plugins)_ Lazy loading
- _(config)_ Lua/abdellatifdev -> lua/adev
- _(plugins)_ Cleaning plugins
- _(plugins)_ Structure
- _(core)_ Changing code structure
- [**breaking**] Internal structure
- _(events)_ Rewrite Event handler
- _(core)_ Refactoring vim.g.adev
- _(core)_ Refactoring vim.g.adev

### 📚 Documentation

- Add contributing and PR guidelines (#1)
- Add contributing and PR guidelines
- _(adev)_ Vim docs
- Cleaning docs
- Fix plugin struture
- Update adev.txt
- _(adev.txt)_ Update
- Update README
- Update CHANGELOG.md
- Update documentation to reflect codebase changes
- Update documentation to reflect codebase changes

### 🎨 Styling

- Unify code formatting
- Stylua toml
- _(stylua)_ Formatting
- Linting

### 🧪 Testing

- _(checkhealth)_ Improve checkhealth

### ⚙️ Miscellaneous Tasks

- Updates docs
- Adding humanity
- _(issue templates)_ Refine templates (#2)
- _(issue templates)_ Refine templates
- _(todo)_ Todo comment to github issues
- _(version)_ 1.2.0
- _(github)_ Pull request template
- _(version)_ Minor update
- Todo.md
- Auto publish

---

## Support

If you find Adev.nvim helpful, consider:

- ⭐ Starring the repository
- 🐛 Reporting issues
- 💡 Suggesting improvements
- ☕ Buying me a coffee

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file
for details.

---

_Generated by [git-cliff](https://git-cliff.org) for Adev.nvim (the
over-engineered nvim distro)_
