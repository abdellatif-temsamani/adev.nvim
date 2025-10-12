> ⚠️ **IMPORTANT NOTICE:**\
> **Israeli users are strictly prohibited from using this project.**\
> **FREE PALESTINE.**
>
> This restriction is imposed as a clear and urgent protest against the ongoing
> occupation, violence, and human rights violations committed by the Israeli
> state against the Palestinian people.\
> By banning usage in Israel, this project stands in solidarity with Palestine
> and calls for justice, freedom, and an end to oppression.

# Adev.nvim 🚀

> The over-engineered Neovim distribution for developers who want everything

Adev.nvim is a feature-rich Neovim configuration that provides a complete
development environment out of the box. Built with modern Neovim features and
carefully selected plugins, it offers blazing-fast performance while maintaining
extensive functionality.

## ✨ Features

### 🎨 **Modern UI & Experience**

- **Catppuccin Mocha Theme**: Beautiful theme with transparent background
  support and dim inactive windows (15% darker)
- **Noice.nvim**: Enhanced cmdline, popupmenu, and notification UI with seamless
  integration
- **Lualine**: Elegant status line with comprehensive git integration
- **Snacks.nvim**: Modern file explorer with netrw replacement, terminal
  integration, and zen mode
- **Status Column**: Enhanced gutter with git signs, fold indicators, and 50ms
  refresh rate
- **blink.cmp Integration**: Consistent UI styling across all completion
  components

### 🔍 **Fuzzy Finding & Navigation**

- **Telescope**: Powerful fuzzy finder with extensive configuration
  - Smart file finding with ripgrep and custom ignore patterns
  - Live grep with advanced filtering (excludes node_modules, .git, build dirs)
  - Buffer, help tags, man pages, and command searching
  - Treesitter symbol navigation
  - Todo comments and Noice message integration
  - Horizontal layout with 99% width/height and 60% preview width
  - Custom borderchars and single border styling

### 🛠️ **Language Support & LSP (40+ Servers)**

- **Mason**: Complete LSP, DAP, and linter management with auto-update
- **Comprehensive LSP Support** including:
  - **Web**: TypeScript/JavaScript (ts_ls, eslint), Vue (vue_ls), HTML/CSS
    (html, cssls, emmet_ls), Svelte, Astro
  - **Backend**: Python (pylsp, pyright, pyre), Rust (rust_analyzer), Go
    (gopls), C/C++ (clangd), PHP (intelephense)
  - **Mobile/Systems**: Java (jdtls), C# (csharp_ls), Zig (zls), Bash (bashls)
  - **Data**: JSON (jsonls), YAML (yamlls), SQL (sqlls), TOML (taplo)
  - **Specialized**: Docker (dockerls), Prisma (prismals), Tailwind
    (tailwindcss), LaTeX (texlab)
  - **Emerging**: Gleam, Slint, Solidity, GLSL, SystemVerilog
- **blink.cmp v1.3.1**: Ultra-fast completion with Rust implementation
  - Cmdline completion with ghost text
  - Auto-show documentation (500ms delay)
  - Laravel-specific completion support
  - LuaSnip integration with friendly-snippets and vim-snippets
- **Advanced LSP Features**: Inlay hints, virtual diagnostic lines, signature
  help

### 🌳 **Code Analysis & Editing**

- **Treesitter**: Advanced syntax highlighting with all parsers installed
- **Treesitter Context**: Show current function/class context (max 2 lines,
  zindex 20)
- **Auto Tags**: Automatic tag closing for HTML/XML/Blade with rename support
- **Smart Comments**: Intelligent comment toggling with context awareness
- **Highlight Colors**: Real-time color preview for hex, rgb, and CSS colors
- **Format Options**: Automatic management to prevent comment continuation

### 🐙 **Git Integration**

- **Gitsigns**: Git status in the gutter with comprehensive hunk management
- **Git Conflict**: Advanced merge conflict resolution helpers
- **Lazygit Integration**: Full terminal-based git client with custom styling
- **GitHub Integration**: Octo.nvim for issues, PRs, and repository management
- **gh-dash**: GitHub dashboard for streamlined workflow management

### 📝 **Productivity Tools**

- **Todo Comments**: Highlight and search TODO/FIXME/NOTE comments with
  Telescope integration
- **Crates.nvim**: Rust crate management with version checking and updates
- **Laravel.nvim**: Laravel/PHP specific features with Blade template support
- **Cloak.nvim**: Hide sensitive environment variables and secrets in files
- **Mini.nvim**: Collection of various productivity mini-plugins
- **Automatic Whitespace Cleanup**: Removes trailing whitespace on save

### ⚡ **Performance Optimizations**

- **Intelligent Lazy Loading**: 22 plugin files with event-based loading using
  186 event definitions
- **Lua Module Caching**: Enabled with `vim.loader.enable(true)` for faster
  startup
- **Rocks & Pkg Support**: Advanced package management with multiple sources
- **Efficient Keymaps**: Space leader with intuitive, categorized bindings
- **Minimal Startup**: Only essential plugins loaded initially, others on-demand
- **Performance Monitoring**: Built-in profiling with `:Lazy profile`
- **Error Handling**: Comprehensive nil-safe configuration access throughout
- **Graceful Fallbacks**: Safe defaults when configuration is unavailable

### 🔧 **System Integration**

- **Health Checks**: Comprehensive 280-line health check system
- **Auto-Update**: Automatic update checking on startup with git integration
- **Nerd Font Support**: Full icon support with compatibility testing
- **Terminal Integration**: Seamless terminal mode with escape key mapping
- **Cross-Platform**: Optimized for Linux, macOS, and Windows
- **Safe Configuration**: Nil-safe access patterns prevent startup errors
- **Defensive Programming**: All functions handle missing configuration
  gracefully

## 🚀 Quick Start

### Prerequisites

#### **Required**

- **Neovim >= 0.11.0** (verified by health checks)
- **Git** (for plugin management and updates)
- **make** (build automation tool)
- **unzip** (archive extraction utility)

#### **Essential Tools**

- **ripgrep** (for telescope live grep and file searching)
- **Nerd Font** (for icons and UI elements)

#### **Optional but Recommended**

- **fd** (faster file finding alternative to find)
- **lazygit** (terminal UI for git operations)
- **gh** (GitHub CLI for GitHub integration)
- **gh-dash** (GitHub dashboard for issue/PR management)
- **bat** (better cat with syntax highlighting)

#### **Language-Specific Tools**

- **Node.js & npm** (for JavaScript/TypeScript LSP servers)
- **Python** (for Python LSP servers and tools)
- **Rust & Cargo** (for rust-analyzer and Rust-based tools)
- **Go** (for gopls and Go development tools)

### Installation

1. **Backup your existing config** (if any):

   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. **Clone Adev.nvim**:

   ```bash
   git clone https://github.com/abdellatif-temsamani/config.nvim ~/.config/nvim
   ```

3. **Start Neovim**:

   ```bash
   nvim
   ```

4. **Wait for setup**: The first time you start Neovim, it will automatically:
   - Install Lazy.nvim plugin manager
   - Download and configure all 22 plugins
   - Install 40+ LSP servers via Mason
   - Install formatters and linters
   - Set up Treesitter parsers
   - Apply Catppuccin Mocha theme

5. **Run health checks**: >
   ```bash
   :checkhealth adev
   ```

## ⚙️ Setup Options

Adev.nvim provides flexible setup options for customization:

### **Basic Setup**

```lua
-- Default setup (recommended for most users)
require("adev").setup()
```

### **Custom Configuration**

```lua
-- Custom setup with options
require("adev").setup({
    git = "/usr/local/bin/git",        -- Custom git path
    colorscheme = "catppuccin-latte"   -- Light theme variant
})
```

### **Available Options**

| Option        | Type   | Default             | Description                                    |
| ------------- | ------ | ------------------- | ---------------------------------------------- |
| `git`         | string | `"git"`             | Git executable path for plugin management     |
| `colorscheme` | string | `"catppuccin-mocha"` | Colorscheme to apply on startup (must be installed first) |

### **Setup Examples**

**Homebrew Git on macOS:**
```lua
require("adev").setup({
    git = "/opt/homebrew/bin/git"
})
```

**Light Theme:**
```lua
require("adev").setup({
    colorscheme = "catppuccin-latte"
})
```

**Full Custom:**
```lua
require("adev").setup({
    git = "/usr/local/bin/git",
    colorscheme = "catppuccin-frappe"
})
```

### **Custom Colorscheme Example**

To use a custom colorscheme, you must first install it:

1. **Add the colorscheme plugin** to `lua/adev/plugins/theme.lua`:
   ```lua
   return {
       {
           "catppuccin/nvim",
           name = "catppuccin",
           priority = 1000,
           opts = { ... }
       },
       {
           "folke/tokyonight.nvim",  -- Your custom colorscheme
           priority = 1000,
           opts = {}
       }
   }
   ```

2. **Then use it in setup**:
   ```lua
   require("adev").setup({
       colorscheme = "tokyonight"
   })
   ```

### **Notes**

- All options are **optional** with safe defaults
- Invalid options fall back to defaults gracefully
- Git path is used for plugin management and updates
- **Custom colorschemes must be installed in plugin specifications before use**
- Catppuccin variants work out-of-the-box (no additional setup required)
- Using an unavailable colorscheme will cause an error

## ⌨️ Key Mappings

> **Leader Key**: `<Space>` (both leader and localleader)

### 🔍 **Navigation & Search**

| Key          | Action             | Description                            |
| ------------ | ------------------ | -------------------------------------- |
| `<leader>ff` | Find files         | Smart file finder with ignore patterns |
| `<leader>fg` | Live grep          | Ripgrep-powered text search            |
| `<leader>fb` | Find buffers       | Buffer navigation                      |
| `<leader>fh` | Help tags          | Search help documentation              |
| `<leader>fm` | Man pages          | Search manual pages                    |
| `<leader>fs` | Commands           | Search available commands              |
| `<leader>fa` | Treesitter symbols | Navigate code symbols                  |
| `<leader>ft` | Todo comments      | Find TODO/FIXME comments               |
| `<leader>fn` | Noice messages     | Search notification history            |

### 🛠️ **LSP & Code Actions**

| Key          | Action               | Description                  |
| ------------ | -------------------- | ---------------------------- |
| `<leader>gd` | Go to definition     | Jump to symbol definition    |
| `<leader>gD` | Go to declaration    | Jump to symbol declaration   |
| `<leader>gh` | Hover documentation  | Show symbol information      |
| `<leader>gi` | Go to implementation | Jump to implementation       |
| `<leader>gr` | Show references      | List all references          |
| `<leader>gt` | Type definition      | Jump to type definition      |
| `<leader>gc` | Code actions         | Show available code actions  |
| `<leader>ga` | Rename symbol        | Rename symbol across project |
| `<leader>gs` | Signature help       | Show function signature      |
| `<leader>go` | Show diagnostics     | Open diagnostic float        |
| `<leader>gp` | Previous diagnostic  | Jump to previous issue       |
| `<leader>gn` | Next diagnostic      | Jump to next issue           |
| `<leader>gl` | Format buffer        | Format code (visual/normal)  |

### 📁 **File & Buffer Management**

| Key          | Action          | Description               |
| ------------ | --------------- | ------------------------- |
| `<leader>bs` | Save buffer     | Write current buffer      |
| `<leader>bp` | Previous buffer | Switch to previous buffer |
| `<leader>bn` | Next buffer     | Switch to next buffer     |
| `<leader>n`  | File explorer   | Open Snacks file explorer |
| `<leader>N`  | Neovim News     | View Neovim news          |

### 🪟 **Window & Tab Management**

| Key          | Action           | Description             |
| ------------ | ---------------- | ----------------------- |
| `<leader>wq` | Close window     | Close current window    |
| `<leader>wd` | Close buffer     | Wipeout current buffer  |
| `<leader>wv` | Vertical split   | Create vertical split   |
| `<leader>wh` | Horizontal split | Create horizontal split |
| `<leader>wp` | Previous tab     | Switch to previous tab  |
| `<leader>wn` | Next tab         | Switch to next tab      |
| `<leader>wo` | New tab          | Create new tab          |
| `<leader>wa` | Toggle zoom      | Zen mode with zoom      |

### 🐙 **Git Operations**

| Key          | Action           | Description           |
| ------------ | ---------------- | --------------------- |
| `<leader>to` | Lazygit          | Open Lazygit terminal |
| `<leader>tq` | GitHub dashboard | Open gh-dash          |

### 🔧 **System & Tools**

| Key          | Action            | Description              |
| ------------ | ----------------- | ------------------------ |
| `<leader>mm` | Mason             | Open Mason interface     |
| `<leader>ml` | Lazy              | Open Lazy.nvim interface |
| `<leader>qq` | Close quickfix    | Close quickfix window    |
| `<leader>qo` | Open quickfix     | Open quickfix window     |
| `<leader>qp` | Previous quickfix | Previous quickfix item   |
| `<leader>qn` | Next quickfix     | Next quickfix item       |

### ⚡ **Quick Actions**

| Key         | Action               | Description             |
| ----------- | -------------------- | ----------------------- |
| `<leader>u` | Move line down       | Move current line down  |
| `<leader>i` | Move line up         | Move current line up    |
| `<leader>Q` | Quit all             | Exit Neovim             |
| `\`         | Unnamed register     | Access system clipboard |
| `j` / `k`   | Visual line movement | Respect wrapped lines   |

### 🎛️ **Split Navigation**

| Key           | Action          | Description          |
| ------------- | --------------- | -------------------- |
| `<C-h/j/k/l>` | Navigate splits | Move between splits  |
| `<M-h/j/k/l>` | Resize splits   | Resize current split |
| `<C-t>`       | Exit terminal   | Exit terminal mode   |

### 📋 **Custom Commands**

| Command          | Description                            |
| ---------------- | -------------------------------------- |
| `:ADInfo`        | Show Adev.nvim version and system info |
| `:ADUpdate`      | Update configuration via git pull      |
| `:ADCheckUpdate` | Check for available updates            |

## 🎨 Theme & Appearance

Adev.nvim uses the **Catppuccin Mocha** theme with extensive customization:

### **Visual Features**

- **Transparent background** support for terminal integration
- **Dim inactive windows** (15% darker for better focus)
- **Integrated styling** across all UI components:
  - blink.cmp completion menus
  - Telescope fuzzy finder
  - Noice enhanced UI
  - Snacks file explorer
  - Gitsigns git integration
- **Consistent borders** (single style throughout)
- **Custom status column** with git signs and fold indicators
- **Enhanced gutter** with 50ms refresh rate for smooth updates

### **UI Components**

- **Lualine**: Elegant statusline with git integration
- **Winbar**: Clean empty space for minimal distraction
- **True color support** for rich visual experience
- **Nerd Font icons** throughout the interface

## 🔧 Architecture & Structure

The distribution follows a modular Lua-based architecture with precise
organization:

### **Core Structure**

```
~/.config/nvim/
├── init.lua (8 lines)                    # Minimal entry point
├── lua/adev/
│   ├── init.lua (97 lines)               # Main module with error handling
│   ├── commands.lua (34 lines)           # Custom commands with safety
│   ├── health.lua (280 lines)            # Comprehensive health checks
│   ├── utils/
│   │   ├── init.lua (52 lines)           # Utility functions with safe access
│   │   ├── update.lua (112 lines)        # Update management with safety
│   │   └── consts/
│   │       ├── init.lua (18 lines)       # Constants
│   │       └── events.lua (186 lines)    # Event definitions
│   ├── config/                           # Configuration modules
│   │   ├── treesitter.lua (21 lines)     # Treesitter setup
│   │   ├── mini.lua                      # Mini.nvim config
│   │   └── none-ls/                      # Formatter configs
│   └── plugins/ (22 files)               # Plugin specifications
├── plugin/                               # Core Neovim settings
│   ├── sets.lua (41 lines)               # Vim options
│   ├── keymaps.lua (42 lines)            # Key mappings
│   ├── autocmd.lua (42 lines)            # Autocommands
│   └── queries/                          # Custom queries
├── doc/adev.txt                          # Comprehensive documentation
└── lazy-lock.json                       # Plugin lockfile
```

### **Plugin Organization (22 Files)**

- **Core**: `lsp.lua` (282 lines), `mason.lua` (116 lines), `telescope.lua` (135
  lines)
- **Completion**: `blink-cmp.lua` (91 lines), `luasnip.lua`
- **UI**: `theme.lua` (30 lines), `snacks.lua` (96 lines), `noice.lua`,
  `lualine.lua`
- **Syntax**: `treesitter.lua` (41 lines), `highlight-colors.lua`,
  `todo-comments.lua`
- **Git**: `gitsigns.lua`, `git-conflict.lua`, `octo.lua`
- **Language-specific**: `laravel.lua`, `crates.lua`, `nvim-jdtls.lua`
- **Tools**: `mini.lua`, `none-ls.lua`, `cloak.lua`, `lazydev.lua`

### **Customization Points**

| Component         | File                             | Purpose                           |
| ----------------- | -------------------------------- | --------------------------------- |
| **Core Settings** | `plugin/sets.lua`                | Vim options, indentation, folding |
| **Key Mappings**  | `plugin/keymaps.lua`             | Global key bindings               |
| **Autocommands**  | `plugin/autocmd.lua`             | Event-driven automation           |
| **Theme**         | `lua/adev/plugins/theme.lua`     | Catppuccin configuration          |
| **LSP**           | `lua/adev/plugins/lsp.lua`       | Language server setup             |
| **Completion**    | `lua/adev/plugins/blink-cmp.lua` | Completion engine                 |
| **Fuzzy Finding** | `lua/adev/plugins/telescope.lua` | Search and navigation             |
| **File Explorer** | `lua/adev/plugins/snacks.lua`    | Modern file management            |

### **Event-Driven Loading**

- **186 event definitions** in `lua/adev/utils/consts/events.lua`
- **Intelligent lazy loading** based on file types, commands, and user actions
- **Performance optimization** with minimal startup impact

## 📊 Performance & Optimization

Adev.nvim is engineered for maximum performance:

### **Startup Optimization**

- **Lua module caching** enabled with `vim.loader.enable(true)`
- **Event-based lazy loading** using 186 categorized events
- **Minimal initial load** - only essential UI components start immediately
- **Smart plugin deferring** with `VeryLazy` event for non-critical plugins
- **Rocks & Pkg support** for efficient package management

### **Runtime Performance**

- **blink.cmp v1.3.1** with Rust implementation for ultra-fast completion
- **Treesitter caching** for syntax highlighting optimization
- **Status column refresh** limited to 50ms for smooth updates
- **Telescope optimizations** with ripgrep and smart ignore patterns
- **LSP capabilities** optimized for blink.cmp integration

### **Memory Management**

- **Lazy plugin loading** - 22 plugins load only when needed
- **Efficient autocommands** with grouped event handling
- **Smart buffer management** with automatic cleanup
- **Optimized file operations** using ripgrep and fd

### **Monitoring Tools**

- **`:Lazy profile`** - Analyze plugin loading times
- **`:checkhealth adev`** - Comprehensive system diagnostics
- **Startup time tracking** with built-in profiling

![Startup Time](./images/startuptime.png)

> **Performance Tip**: Run `:Lazy profile` to identify any slow-loading plugins
> and optimize your setup further.

## 🛠️ Language Support (40+ LSP Servers)

Adev.nvim provides comprehensive language support with automatic LSP server
installation:

### **Web Development**

| Language                  | LSP Server                                | Features                                     |
| ------------------------- | ----------------------------------------- | -------------------------------------------- |
| **JavaScript/TypeScript** | `ts_ls`, `eslint`, `biome`                | Full LSP, linting, formatting                |
| **Vue.js**                | `vue_ls`                                  | TypeScript SDK integration                   |
| **HTML**                  | `html`, `emmet_ls`                        | Multi-framework support (Astro, Blade, etc.) |
| **CSS**                   | `cssls`, `css_variables`, `cssmodules_ls` | Variables, modules, Tailwind                 |
| **Svelte**                | `svelte`                                  | Full framework support                       |
| **Astro**                 | `astro`                                   | Modern web framework                         |

### **Backend & Systems**

| Language   | LSP Server                 | Features                              |
| ---------- | -------------------------- | ------------------------------------- |
| **Python** | `pylsp`, `pyright`, `pyre` | Multiple LSPs, type checking          |
| **Rust**   | `rust_analyzer`            | Crates integration, advanced features |
| **Go**     | `gopls`                    | Full Go toolchain support             |
| **C/C++**  | `clangd`                   | CMake integration                     |
| **Java**   | `jdtls`                    | Eclipse JDT language server           |
| **C#**     | `csharp_ls`                | .NET development                      |
| **PHP**    | `intelephense`             | Premium features with license key     |

### **Modern Languages**

| Language     | LSP Server                                | Features               |
| ------------ | ----------------------------------------- | ---------------------- |
| **Zig**      | `zls`                                     | Systems programming    |
| **Gleam**    | `gleam`                                   | Functional programming |
| **Slint**    | `slint_lsp`                               | UI development         |
| **Solidity** | `solidity`, `solidity_ls_nomicfoundation` | Smart contracts        |

### **Data & Configuration**

| Language | LSP Server | Features            |
| -------- | ---------- | ------------------- |
| **JSON** | `jsonls`   | Schema validation   |
| **YAML** | `yamlls`   | Configuration files |
| **TOML** | `taplo`    | Rust/Python configs |
| **SQL**  | `sqlls`    | Database queries    |
| **XML**  | `lemminx`  | Document processing |

### **Specialized Tools**

| Tool              | LSP Server                                    | Purpose               |
| ----------------- | --------------------------------------------- | --------------------- |
| **Docker**        | `dockerls`, `docker_compose_language_service` | Container development |
| **Prisma**        | `prismals`                                    | Database ORM          |
| **Tailwind CSS**  | `tailwindcss`                                 | Utility-first CSS     |
| **LaTeX**         | `texlab`                                      | Document preparation  |
| **GLSL**          | `glslls`, `glsl_analyzer`                     | Shader development    |
| **SystemVerilog** | `svlangserver`, `svls`                        | Hardware description  |
| **Bash**          | `bashls`                                      | Shell scripting       |
| **GDScript**      | `gdscript`                                    | Godot game engine     |

### **Framework-Specific Features**

- **Laravel**: Blade template support with auto-completion
- **Vue.js**: TypeScript SDK integration with custom tsdk path
- **Emmet**: Multi-framework support (React, Vue, Svelte, Astro)
- **Tailwind**: Custom class regex patterns for cva() and cn() functions

## 🔧 Health Checks & Diagnostics

Adev.nvim includes a comprehensive health check system with 280 lines of
diagnostic code:

### **System Verification**

```bash
:checkhealth adev          # Adev-specific checks
:checkhealth               # All components
:checkhealth lazy          # Plugin manager
:checkhealth mason         # LSP servers
:checkhealth telescope     # Fuzzy finder
```

### **Health Check Categories**

- **Neovim Version**: Verifies >= 0.11.0 requirement
- **Required Executables**: git, make, unzip (critical)
- **Optional Tools**: ripgrep, lazygit, gh, fd, bat (with install instructions)
- **Lua Modules**: Validates adev core modules
- **Nerd Font Support**: Tests icon display with examples
- **System Information**: OS, architecture, terminal detection
- **Configuration**: Validates setup and module loading

## 🚀 Quick Start Commands

After installation, try these commands to explore Adev.nvim:

```vim
:ADInfo                    " Show version and system info
:ADCheckUpdate            " Check for configuration updates
:checkhealth adev         " Run comprehensive health checks
:Lazy                     " Manage plugins
:Mason                    " Manage LSP servers and tools
:Telescope find_files     " Find files with smart filtering
:help adev                " Open comprehensive documentation
```

## 🤝 Contributing

This is a personal Neovim distribution tailored to my workflow. While I
appreciate suggestions and feedback, I am only accepting pull requests that
address bug fixes. I'm not sure about accepting all fix pull requests, but you
are welcome to:

- **Fork** the repository for your own use
- **Open issues** for bugs or feature requests
- **Adapt** the distribution to your needs
- **Share improvements** in the community

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE)
file for details.

## 📈 Project Statistics

- **Total Files**: 50+ configuration files
- **Plugin Files**: 22 modular plugin configurations
- **LSP Servers**: 40+ language servers supported
- **Event Definitions**: 186 categorized events for lazy loading
- **Health Checks**: 280 lines of diagnostic code
- **Key Mappings**: 60+ organized key bindings
- **Documentation**: Comprehensive help system with `:help adev`
- **Languages Supported**: 25+ programming languages
- **Autocommands**: 5 intelligent automation rules
- **Update System**: Automatic update checking and git integration
- **Error Handling**: Comprehensive nil-safe patterns throughout codebase
- **Code Quality**: Defensive programming with graceful fallbacks

## 🙏 Acknowledgments

Special thanks to the amazing Neovim plugin ecosystem:

### **Core Infrastructure**

- [folke/lazy.nvim](https://github.com/folke/lazy.nvim) - Revolutionary plugin
  manager with lazy loading
- [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) - LSP client
  configurations
- [mason-org/mason.nvim](https://github.com/mason-org/mason.nvim) -
  LSP/DAP/linter installer

### **UI & Experience**

- [catppuccin/nvim](https://github.com/catppuccin/nvim) - Beautiful, soothing
  pastel theme
- [folke/snacks.nvim](https://github.com/folke/snacks.nvim) - Modern UI
  components and utilities
- [folke/noice.nvim](https://github.com/folke/noice.nvim) - Enhanced cmdline and
  notification UI
- [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) -
  Blazing fast statusline

### **Navigation & Search**

- [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) -
  Highly extendable fuzzy finder
- [nvim-lua/plenary.nvim](https://github.com/nvim-lua/plenary.nvim) - Essential
  Lua utilities

### **Completion & Snippets**

- [saghen/blink.cmp](https://github.com/saghen/blink.cmp) - Ultra-fast
  completion with Rust implementation
- [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) - Powerful snippet
  engine
- [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) -
  Comprehensive snippet collection

### **Syntax & Editing**

- [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) -
  Advanced syntax highlighting
- [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) -
  Automatic tag closing
- [nvim-treesitter/nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context) -
  Context awareness

### **Git Integration**

- [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) - Git
  signs and hunks
- [akinsho/git-conflict.nvim](https://github.com/akinsho/git-conflict.nvim) -
  Merge conflict resolution

---

**Happy coding with Adev.nvim! 🚀**

> _"The over-engineered Neovim distribution for developers who want everything"_
