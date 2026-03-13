# Changelog

All notable changes to Adev.nvim (the over-engineered nvim distro) will be documented in this file.

This changelog is automatically generated using [git-cliff](https://git-cliff.org).

## About

Adev.nvim is an over-engineered Neovim distribution maintained by Abdellatif Dev, featuring a modern and efficient development environment with carefully curated plugins and settings.

## [2.0.6] - 2026-03-13

### 🚀 Features

- *(laravel)* Improve plugin config

### 🐛 Bug Fixes

- *(adev-files)* File sync
- Harden window close handling in navigation quit
- *(snacks)* Disable file-manager
- *(mason)* Add missing package
- *(blink-cmp)* Remove blink-calc
- Theme defaults

### 💼 Other

- Adev-files (#14)

### 🚜 Refactor

- *(adev-files)* Unify sync
- *(adev-files)* Rewrite
- *(adev-files)* Sensible defaults

### ⚙️ Plugins

- *("markdown")* Add render-markdown
- *(lspconfig)* Add timeout to vim format
- *(markdown)* Switched tj present
- *(snacks)* Disable image preview

## [2.0.5-1] - 2026-01-31

### 🚀 Features

- Implement virtual text for file manager UI

### 🐛 Bug Fixes

- Compare current version with latest in check_update
- *(adev-files)* Create new file
- *(adev-files)* Rename

### 💼 Other

- Adev-files
- Adev-files

### 🚜 Refactor

- *(adev-files)* Index by filename instead of line number
- Consolidate utilities and add feature flags system (#8)
- *(adev-files)* Use <nop> to disable keymaps

## [2.0.5] - 2026-01-30

### 🚀 Features

- *(plugins)* Mdx filetype support
- *(adev-files)* Structuring core plugin
- *(adev)* Major refactor of file manager and UI infrastructure
- Adev-files
- *(adev-files)* Mini-icons support
- *(adev-files)* Opening files
- *(core)* Lazy laoding

### 🐛 Bug Fixes

- *(changelog)* Version display in the title
- *(lspconfig)* Lua_ls load
- Conflict lua_ls x stylua on code formatting
- *(adev-files)* Window sizing

### 💼 Other

- *(telescope)* Changing keymaps

### 🚜 Refactor

- Restructure file manager and remove deprecated code
- *(core)* Big refactor
- *(adev-files)* Change keymap to <leader>n

### 📚 Documentation

- *(requirement)* Update min version of deps

### ⚙️ Plugins

- *(none-ls)* Disabled rustywind
- *(adev-files)* Disable some keymaps

### ⚙️ Miscellaneous Tasks

- Update cliff.toml
- Coderabbit suggestions

## [2.0.4] - 2026-01-20

### 🚀 Features

- *(update_manager)* [**breaking**] New update method
- *(blink.cmp)* Enhance completion with mini.icons and add JS/TS snippets
- Add custom vscode snippets support

### 🐛 Bug Fixes

- *(update_manager)* Update
- *(update_manager)* Fetch remote tags
- *(blink)* Sorting
- *(mini-files)* Opens in current buf's dir

### 🚜 Refactor

- *(lualine)* [**breaking**] Replace winbar with tabline.windows
- *(lualine)* Change placing of lsp status
- *(core-plugin)* Re-structure adev core plugins
- Simplify file explorer configuration and remove telescope dependency

### 📚 Documentation

- *(adev.txt)* Refactor docs
- Update README and help to use :ADConfig for configuration

### ◀️ Revert

- Disable ghost_line

## [2.0.3] - 2026-01-11

### 🚀 Features

- Add feature flags system for experimental features (#5)

### 🐛 Bug Fixes

- Improve remote tag fetching and async handling

### 🚜 Refactor

- Improve onboarding module structure
- Consolidate update_manager into single module
- Extract git utilities to common module
- *(utils)* Restart_nvim to nvim
- Unify window and buffer creation API
- *(utils)* Restart neovim take 2000ms instead of 1500ms
- *(blink)* Start on CmdEnter
- Consolidate types and improve error handling

### ⚙️ Miscellaneous Tasks

- Fix dupe @return
- *(coderabbit)* Added .coderabbit.yaml

## [2.0.2] - 2026-01-09

### 🚀 Features

- Add build command for Catppuccin theme
- Update treesitter
- Adev-files
- *(core)* Spliting to adev, adev-common
- *(adev-files)* List files
- Add build command for Catppuccin theme
- Update treesitter
- Adev-files
- *(core)* Spliting to adev, adev-common
- *(adev-files)* List files
- Add feature flags system

### 🐛 Bug Fixes

- *(treesitter)* Add ipkg to ignore_install list
- Remove those annoying arg auto fill snippets
- *(blink)* Cmdline completions
- *(onboarding)* If init.lua exist but init-opts.lua not found edge case
- *(core)* Fix onboarding
- Get_dirname
- *(blink)* Completions
- Spelling
- *(treesitter)* Add ipkg to ignore_install list
- Treesitter
- Remove those annoying arg auto fill snippets
- *(blink)* Cmdline completions
- *(onboarding)* If init.lua exist but init-opts.lua not found edge case
- *(core)* Fix onboarding
- Get_dirname
- *(blink)* Completions
- Spelling
- Refactor config merging to properly handle user-only keys
- *(typo)* Lua/adev-common/utils/files.lua
- Docs
- *(adev-files)* Expand paths consistently before file operations

### 🚜 Refactor

- *(onboarding)* ADConfig hot-reloads nvim
- *(plugins)* Changing plugins configs
- *(mini)* Move to standalone mini.nvim plugins
- *(adev-files)* Common-utils
- Simplify mini plugin spec nesting and update UI structure
- Improve neovim config utilities and plugin settings
- *(adev-files)* Refactor list files to open in a floating window
- *(adev-files)* List files improve highlighting
- Improve input UI signature and centralize file operations
- Improve code structure and error handling
- *(onboarding)* ADConfig hot-reloads nvim
- *(plugins)* Changing plugins configs
- *(mini)* Move to standalone mini.nvim plugins
- *(adev-files)* Common-utils
- Simplify mini plugin spec nesting and update UI structure
- Improve neovim config utilities and plugin settings
- *(adev-files)* Refactor list files to open in a floating window
- *(adev-files)* List files improve highlighting
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

- *(laravel)* Switch to laravel
- *(adev-files)* List files help index
- Add project-specific git attributes for neovim config
- *(laravel)* Switch to laravel
- *(adev-files)* List files help index
- Add project-specific git attributes for neovim config

## [2.0.1] - 2025-12-23

### 🚀 Features

- Add treesitter auto-start configuration and update project release name
- Temp implementation of ADConfig

### 🐛 Bug Fixes

- *(gitsigns)* Lazyloading
- Add assertion for LSP defaults in lsp.lua
- Treesitter config

### 📚 Documentation

- Update CHANGELOG.md
- Update documentation to reflect codebase changes
- Update documentation to reflect codebase changes

### ⚙️ Miscellaneous Tasks

- Auto publish

## [1.5.0] - 2025-10-19

### 🚀 Features

- More info
- New utils function
- Opts "git"
- Opts "colorscheme"
- *(blink-cmp)* Calc source
- *(null-ls)* Added stylua
- *(new-plugin)* [**breaking**] Augment
- *(set)* More options

### 🐛 Bug Fixes

- *(blink.cmp)* Config
- Version
- Check update
- *(laravel)* Fix lazyloading
- Lazy loading
- Lazyloading
- Luadocs
- Queries
- *(comments)* Lazyloading conditions
- *(mason)* Lazyloading
- *(mason)* Plugin not loading
- [**breaking**] Lazy loading condition
- *(mason-lspconfig)* Origin
- Config
- *(options)* Border = 'single'
- *(plugins)* Event loading
- *(treesitter)* Not loading
- *(plugins)* Lazy loading conditions

### 🚜 Refactor

- *(core)* Changing code structure
- [**breaking**] Internal structure
- *(events)* Rewrite Event handler
- *(core)* Refactoring vim.g.adev
- *(core)* Refactoring vim.g.adev

### 📚 Documentation

- Fix plugin struture
- Update adev.txt
- *(adev.txt)* Update
- Update README

### 🎨 Styling

- Unify code formatting
- Stylua toml
- *(stylua)* Formatting
- Linting

### ⚙️ Miscellaneous Tasks

- Todo.md

## [1.4.0] - 2025-10-08

### 🚀 Features

- *(cmp)* [**breaking**] Blink-cmp -> nvim-cmp
- Godot linting
- Gdformat use spaces
- Auto check for update
- *(autocmd)* Gdscript space
- *(cmp)* Back to blink.cmp v1.3.1
- *(lua)* Vim highlight as builtin
- [**breaking**] Lua_ls hints

### 🐛 Bug Fixes

- [**breaking**] Cmp
- Sets config

### 📚 Documentation

- Cleaning docs

## [1.3.1] - 2025-09-15

### 🚀 Features

- *(health)* Healthcheck adev
- *(blink-cmp)* Conventional-commits
- *(blink-cmp)* Ghostline cmdline
- *(noice)* Override defaults
- *(lsp)* Tailwindcss config
- *(blink.nvim)* [**breaking**] Removing providers

### 🐛 Bug Fixes

- *(treesitter)* Plugin event
- *(telescope)* Border style
- *(laravel)* Missing deps
- Better notifications
- *(laravel)* [**breaking**] Fix commands

### 🚜 Refactor

- *(plugins)* Structure

### 📚 Documentation

- *(adev)* Vim docs

### 🧪 Testing

- *(checkhealth)* Improve checkhealth

### ⚙️ Miscellaneous Tasks

- *(version)* Minor update

## [1.2.0] - 2025-08-02

### 🚀 Features

- *(snacks)* Add image support
- *(lsp)* Diagonistic vertual line [expermental]
- *(config)* Mv config to lua/abdellatifdev/config
- *(git-worktree)* [**breaking**] Rm plugins

### 🐛 Bug Fixes

- *(theme)* Align with telescope and snacks
- *(lualine)* Winbar now displays "Adev.nvim" instead of "abdellatif dev"
- *(blink.cmp)* Downgrade to "v1.3.1"
- *(crates.nvim)* Add event for lazy loading

### 🚜 Refactor

- *(notification)* Changes notification handling
- *(theme)* Optimize opts
- *(theme)* Optimize config
- *(plugins)* Lazy = true as default value
- *(comments)* Change config
- *(ui)* Border styles
- *(plugins)* Lazy loading
- *(config)* Lua/abdellatifdev -> lua/adev
- *(plugins)* Cleaning plugins

### 📚 Documentation

- Add contributing and PR guidelines (#1)
- Add contributing and PR guidelines

### ⚙️ Miscellaneous Tasks

- Updates docs
- Adding humanity
- *(issue templates)* Refine templates (#2)
- *(issue templates)* Refine templates
- *(todo)* Todo comment to github issues
- *(version)* 1.2.0
- *(github)* Pull request template

## [1.1.0] - 2025-07-30

### 🚀 Features

- Lazy laoding
- Nvim-cmp -> blink-cmp
- Mini.nvim && cleaning plugins
- Config to distro

### 🐛 Bug Fixes

- Readme
- Snacks
- Lsp keymaps
- *(blink.cmp)* Temp fix

---

## Support

If you find Adev.nvim helpful, consider:
- ⭐ Starring the repository
- 🐛 Reporting issues
- 💡 Suggesting improvements
- ☕ Buying me a coffee

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Generated by [git-cliff](https://git-cliff.org) for Adev.nvim (the over-engineered nvim distro)*
