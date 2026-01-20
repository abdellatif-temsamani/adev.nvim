> **Personal Statement**
>
> I stand in solidarity with the Palestinian people and support their
> fundamental human rights. I oppose ongoing violence, occupation, and human
> rights violations, and I call for justice, dignity, and freedom for all.

# Adev.nvim 🚀

> The over-engineered Neovim distribution for developers who want everything

![GitHub Release](https://img.shields.io/github/v/release/abdellatif-temsamani/adev.nvim?display_name=tag&style=flat-square&color=blue)
![GitHub top language](https://img.shields.io/github/languages/top/abdellatif-temsamani/adev.nvim?style=flat-square&color=blue)
![GitHub Release Date](https://img.shields.io/github/release-date-pre/abdellatif-temsamani/adev.nvim?display_date=published_at&style=flat-square&color=blue)
![Static Badge](https://img.shields.io/badge/Neovim-v0.11.5-blue?style=flat-square&logo=neovim)
![GitHub License](https://img.shields.io/github/license/abdellatif-temsamani/adev.nvim?style=flat-square&color=blue)


Adev.nvim is a feature-rich Neovim configuration that provides a complete
development environment out of the box. Built with modern Neovim features and
carefully selected plugins, it offers blazing-fast performance while maintaining
extensive functionality. Includes custom-plugin support, update-manager,
feature-flags system, and ADConfig for easy configuration.

## Table of Contents

- [🚀 Installation](#-installation)
- [✨ Features](#-features)
- [🔧 Custom Plugins](#-custom-plugins)
- [📖 Usage](#-usage)
- [📊 Performance](#-performance)
- [🤝 Contributing](#-contributing)

## 🚀 Installation

### Prerequisites

- Neovim 0.11.0 or higher
- Git
- Node.js 16+ (for LSP servers)
- A terminal with modern features

### Quick Setup

1. **Clone the repository:**

   ```bash
   git clone https://github.com/abdellatif-temsamani/adev.nvim ~/.config/nvim
   ```

2. **Start Neovim:**

   ```bash
   nvim
   ```

3. **Install plugins:**
   ```vim
   :Lazy sync
   ```

That's it! Adev.nvim will automatically install all plugins and LSP servers on
first run.

## ✨ Features

- **Plugin Management**: lazy.nvim package manager with lazy-loaded plugins and
  30+ carefully selected plugins
- **LSP Support**: Built-in Language Server Protocol support for 30+ languages
- **Modern Completion**: Blink.cmp with fuzzy matching and snippet support
- **Syntax Highlighting**: Tree-sitter for advanced syntax parsing
- **Git Integration**: Git signs, blame, hunk navigation, and GitHub integration
- **UI Enhancements**: Custom status line, notifications, and file explorer
- **Feature Flags**: Toggle experimental features and plugins
- **Custom Plugins**: Easy-to-add user plugins without modifying core files
- **Update Manager**: Automatic update checking and seamless upgrades
- **ADConfig**: Modular configuration system for easy customization

## 🔧 Custom Plugins

Adev.nvim supports adding your own custom plugins without modifying the core
configuration. Custom plugins are stored in the `lua/adev/custom-plugins/`
directory.

### Adding a Custom Plugin

Create a new file in `lua/adev/custom-plugins/`, for example `my-plugin.lua`:

```lua
return {
  {
    "author/plugin-name",
    opts = {
      -- config here
    },
    keys = {
      { "<leader>mp", "<cmd>MyPluginCommand<cr>", desc = "My plugin command" }
    }
  }
}
```

### Caution: Custom Plugins are Git Ignored

⚠️ **Important**: Custom plugins in `lua/adev/custom-plugins/` are intended for
personal use and are not tracked by version control. This prevents committing
personal or sensitive plugin configurations to the repository.

If you want to share your custom plugins or include them in version control,
consider:

- Moving them to a separate repository
- Using a fork of Adev.nvim
- Contributing them upstream if they benefit the community

## 📖 Usage

### Basic Navigation

- `<leader>ff` - Find files
- `<leader>fg` - Grep search
- `<leader>n` - Open file explorer
- `<leader>b` - List buffers

### Code Development

- `<leader>gd` - Go to definition
- `<leader>gr` - Find references
- `<leader>gc` - Code actions
- `<leader>gf` - Format code

### Example Workflow

1. Open a project: `cd my-project && nvim`
2. Find files: `<leader>ff`
3. Start coding with LSP autocompletion
4. Use `<leader>gc` for quick fixes
5. Commit changes with git integration

For comprehensive keybindings and advanced usage, see `doc/adev.txt`.

## 📊 Performance

![Startup Time](./images/startuptime.png)

_Startup time measured on a typical development machine using Lazy.nvim._

- **Average startup**: ~50-100ms
- **Memory usage**: Optimized with lazy loading
- **Plugin count**: 30+ plugins with conditional loading
- **LSP servers**: Auto-installed only when needed

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for
guidelines.
