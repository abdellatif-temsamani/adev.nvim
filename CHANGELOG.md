# Changelog

All notable changes to Adev.nvim (the over-engineered nvim distro) will be documented in this file.

This changelog is automatically generated using [git-cliff](https://git-cliff.org).

## About

Adev.nvim is an over-engineered Neovim distribution maintained by Abdellatif Dev, featuring a modern and efficient development environment with carefully curated plugins and settings.

## [2.0.0-2] - 2025-10-30

### 🚀 Features

- *(lspsaga)* Config
- Basic onboarding

### 🐛 Bug Fixes

- Uptodate notification
- <C-A>
- Telescope borders
- Adev global

### ◀️ Revert

- *(plugins)* Remove lspsaga

## [2.0.0-1] - 2025-10-27

### 🚀 Features

- Setup lazy.nvim package manager
- *(plugins)* Theme and statusline
- Options
- *(plugins)* Blink-cmp
- Minimal autocmd setup
- *(plugins)* Telescope
- *(plugins)* Lazydev
- *(plugins)* Lspconfig, mason
- *(plugins)* Restoring to v1.5 status
- Lazyloading
- *(core)* Lazy.nvim opts
- *(lsp)* Customizable lsp servers
- *(config)* Ai assistant
- Activate ai plugin for testing
- *(autocmd)* C and cpp get tab=2
- *(config)* Rm init.lua
- Ui & theme opts
- Example plugin
- Notify utils
- *(core)* Update manager
- User commands
- Adev ui
- *(plugin)* Add lspsaga
- *(plugin)* Add lspsaga event

### 🐛 Bug Fixes

- *(gitsigns)* Lazyloading
- *(lualint)* Rm duplicated status
- *(theme)* Improve setup
- Formatting
- *(lualine)* Optimize config
- Treesitter
- *(telescope)* Smaller preview width
- *(telescope)* Switch colorscheme
- Docs
- Types

### 💼 Other

- Check git cmd from opts

### 🚜 Refactor

- *(plugins)* File naming
- *(config)* Move theme to catppuccin
- Update manager
- *(lsp)* Moving out of utils
- Simplify adev.ui.border

### 📚 Documentation

- *(README)* Refactoring

### 🎨 Styling

- Code formatting

### ⚙️ Miscellaneous Tasks

- Code formatting
- TODO.md
- Formatting

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
