# Changelog

All notable changes to Adev.nvim (the over-engineered nvim distro) will be
documented in this file.

This changelog is automatically generated using
[git-cliff](https://git-cliff.org).

## About

Adev.nvim is an over-engineered Neovim distribution maintained by Abdellatif
Dev, featuring a modern and efficient development environment with carefully
curated plugins and settings.

## [2.0.0-2] - 2025-10-30

### 🚀 Features

- _(lspsaga)_ Config
- Basic onboarding

### 🐛 Bug Fixes

- Uptodate notification
- <C-A>
- Telescope borders
- Adev global

### ◀️ Revert

- _(plugins)_ Remove lspsaga

## [2.0.0-1] - 2025-10-27

### 🚀 Features

- Setup lazy.nvim package manager
- _(plugins)_ Theme and statusline
- Options
- _(plugins)_ Blink-cmp
- Minimal autocmd setup
- _(plugins)_ Telescope
- _(plugins)_ Lazydev
- _(plugins)_ Lspconfig, mason
- _(plugins)_ Restoring to v1.5 status
- Lazyloading
- _(core)_ Lazy.nvim opts
- _(lsp)_ Customizable lsp servers
- _(config)_ Ai assistant
- Activate ai plugin for testing
- _(autocmd)_ C and cpp get tab=2
- _(config)_ Rm init.lua
- Ui & theme opts
- Example plugin
- Notify utils
- _(core)_ Update manager
- User commands
- Adev ui
- _(plugin)_ Add lspsaga
- _(plugin)_ Add lspsaga event

### 🐛 Bug Fixes

- _(gitsigns)_ Lazyloading
- _(lualint)_ Rm duplicated status
- _(theme)_ Improve setup
- Formatting
- _(lualine)_ Optimize config
- Treesitter
- _(telescope)_ Smaller preview width
- _(telescope)_ Switch colorscheme
- Docs
- Types

### 💼 Other

- Check git cmd from opts

### 🚜 Refactor

- _(plugins)_ File naming
- _(config)_ Move theme to catppuccin
- Update manager
- _(lsp)_ Moving out of utils
- Simplify adev.ui.border

### 📚 Documentation

- _(README)_ Refactoring

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
- _(blink-cmp)_ Calc source
- _(null-ls)_ Added stylua
- _(new-plugin)_ [**breaking**] Augment
- _(set)_ More options

### 🐛 Bug Fixes

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

### 🚜 Refactor

- _(core)_ Changing code structure
- [**breaking**] Internal structure
- _(events)_ Rewrite Event handler
- _(core)_ Refactoring vim.g.adev
- _(core)_ Refactoring vim.g.adev

### 📚 Documentation

- Fix plugin struture
- Update adev.txt
- _(adev.txt)_ Update
- Update README

### 🎨 Styling

- Unify code formatting
- Stylua toml
- _(stylua)_ Formatting
- Linting

### ⚙️ Miscellaneous Tasks

- Todo.md

## [1.4.0] - 2025-10-08

### 🚀 Features

- _(cmp)_ [**breaking**] Blink-cmp -> nvim-cmp
- Godot linting
- Gdformat use spaces
- Auto check for update
- _(autocmd)_ Gdscript space
- _(cmp)_ Back to blink.cmp v1.3.1
- _(lua)_ Vim highlight as builtin
- [**breaking**] Lua_ls hints

### 🐛 Bug Fixes

- Sets config

### 📚 Documentation

- Cleaning docs

## [1.3.1] - 2025-09-15

### 🚀 Features

- _(health)_ Healthcheck adev
- _(blink-cmp)_ Conventional-commits
- _(blink-cmp)_ Ghostline cmdline
- _(noice)_ Override defaults
- _(lsp)_ Tailwindcss config
- _(blink.nvim)_ [**breaking**] Removing providers

### 🐛 Bug Fixes

- _(treesitter)_ Plugin event
- _(telescope)_ Border style
- _(laravel)_ Missing deps
- Better notifications
- _(laravel)_ [**breaking**] Fix commands

### 🚜 Refactor

- _(plugins)_ Structure

### 📚 Documentation

- _(adev)_ Vim docs

### 🧪 Testing

- _(checkhealth)_ Improve checkhealth

### ⚙️ Miscellaneous Tasks

- _(version)_ Minor update

## [1.2.0] - 2025-08-02

### 🚀 Features

- _(snacks)_ Add image support
- _(lsp)_ Diagonistic vertual line [expermental]
- _(config)_ Mv config to lua/abdellatifdev/config
- _(git-worktree)_ [**breaking**] Rm plugins

### 🐛 Bug Fixes

- _(theme)_ Align with telescope and snacks
- _(lualine)_ Winbar now displays "Adev.nvim" instead of "abdellatif dev"
- _(blink.cmp)_ Downgrade to "v1.3.1"
- _(crates.nvim)_ Add event for lazy loading

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

### 📚 Documentation

- Add contributing and PR guidelines (#1)
- Add contributing and PR guidelines

### ⚙️ Miscellaneous Tasks

- Updates docs
- Adding humanity
- _(issue templates)_ Refine templates (#2)
- _(issue templates)_ Refine templates
- _(todo)_ Todo comment to github issues
- _(version)_ 1.2.0
- _(github)_ Pull request template

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
- _(blink.cmp)_ Temp fix

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
