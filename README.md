# README for `config.nvim`

Welcome to my Neovim configuration repository! This repo contains all the
configuration files and settings I use to customize and enhance my Neovim
experience. Whether you're new to Neovim or looking for inspiration for your own
setup, feel free to explore and use anything you find helpful.

## 🚀 Features

- **Modern Neovim:** Leverages the latest Neovim features (>=0.9).
- **Plugin Management:** I'm Using
  [lazy.nvim](https://github.com/folke/lazy.nvim).
- **LSP Ready:** Full support for Language Server Protocol (LSP) with
  diagnostics, auto-completions, and code actions.
- **Treesitter Integration:** Syntax highlighting and advanced code analysis
  powered by Treesitter.
- **Telescope:** Fuzzy finder for files, buffers, and more.
- **Custom Keymaps:** Streamlined and efficient key mappings for productivity.
- **Performance Optimizations:** Configured for speed and responsiveness.

## 🛠️ Setup

### Prerequisites

1. **Neovim (>=0.9)**\

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/abdellatif-temsamani/config.nvim ~/.config/nvim
   ```

2. Install plugins: Open Neovim.

3. Restart Neovim: (optional)

## 🔧 Customization

Feel free to customize the configuration files to suit your needs. Most key
settings are located in:

- **[./plugin/sets.lua](plugin/sets.lua)** for core options.
- **[./plugin/autocmd.lua](./plugin/autocmd.lua)** for auto commands.
- **[plugin/keymaps.lua](./plugin/keymaps.lua)** for custom key bindings.
- **[lua/abdellatifdev/plugins](./lua/abdellatifdev/plugins)** for individual
  plugin configurations.

## 📜 Key Features Breakdown

### Core Plugins

- **LSP Configurations:**\
  Uses [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) for setting up
  popular language servers.

- **Treesitter:**\
  Syntax highlighting and parsing with
  [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter).

- **Telescope:**\
  Fuzzy finding with
  [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).

- **Status Line and Tabline:**\
  Enhanced UI with plugins like
  [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)

- **File Explorer:**\
  Integration with [nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)

## 🤝 Contributing

If you have suggestions or improvements, feel free to open an issue.

## ❗ Note on Contributions

All pull requests to this repository will be closed. This configuration is
personal and tailored to my workflow. Feel free to fork it and adapt it to your
needs, but I will not be accepting contributions.

## 📄 License

This configuration is licensed under the MIT License. See [LICENSE](./LICENSE)
for details.

Enjoy hacking with Neovim! 🚀
