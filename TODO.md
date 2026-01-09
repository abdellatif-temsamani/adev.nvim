# Adev.nvim TODO & Enhancement List

## 🔧 Setup Options to Add

## plugins considered for addition

- lewis6991/hover.nvim

### core features

those will be core features that are required for adev to work

- [x] `update_manager` - `:AdevUpdate` and `:AdevUpdateCheck` commands
- [x] `changelog` - `:AdevChangelog` command to show latest chances depends on
      git tags and [changelog](./CHANGELOG.md) file
- [ ] `telescope integration` - create a telescope picker for adev to show
      helpful information
- [ ] `onboarding` - create a onboarding system for adev to show helpful (for
      new users)

### Core Configuration

- [x] `leader` - Custom leader key (default: " ")
- [x] `localleader` - Custom local leader key (default: " ")
- [x] `lazy_loading` - Control lazy loading behavior (default: true)
- [x] `auto_update_check` - Enable/disable startup update checks (default: true)
- [x] `version` - lazy.nvim defualt.version (default: nil)
- [ ] `performance_mode` - Optimize for performance vs features (default: false)
- [ ] `mouse support` - Enable mouse support (default: false)
- [x] `ai` - Enable/disable AI assistance (default: false)
- [x] `ai_plugin` - AI assistance plugin to use (default:
      "supermaven-inc/supermaven-nvim")
- [x] `colorscheme` - Colorscheme to use (default: "catppuccin-mocha")
- [x] `plugins` - Custom list of plugins to install
- [ ] `plugins_opts` - disable/enable certain core plugins

### UI & Theme Options

- [x] `transparent_bg` - Enable transparent background (default: false)
- [ ] `icons` - Enable/disable nerd font icons (default: true)
- [x] `borders` - Border style for UI elements ("single", "rounded", "none")
- [ ] `dim_inactive` - Dim inactive windows percentage (default: 0.1)

### LSP & Completion

- [x] `lsp` - Enable/disable LSP (default: true)
- [x] `lsp_servers` - Custom list of LSP servers to install
- [ ] `diagnostics` - LSP diagnostics configuration
  - [ ] `virtual_text` - Enable virtual diagnostic text
  - [ ] `signs` - Enable diagnostic signs in collumn line

### File Management

- [ ] `custom ui for file management` replaces snacks explorer
- [ ] `auto_save` - Enable auto-save functionality
- [ ] `backup` - Enable backup files
- [ ] `swap` - Enable swap files
- [ ] `undo_levels` - Number of undo levels (default: 1000)

### Git Integration

- [x] `git_signs` - Enable/disable git signs in gutter
- [x] `git_blame` - Enable git blame integration
- [x] `lazygit` - lazygit floating window

## 🚀 Feature Enhancements

### Plugin Additions

- [x] **AI Integration**
  - [x] custom AI assistance
- [x] **Enhanced Git**
  - [x] diffview.nvim for better diffs
  - [x] GitHub integration improvements

### UI Improvements

- [x] **Which-key Integration**
  - [x] Key binding discovery
  - [x] Contextual help
- [x] **Enhanced Notifications**
  - [x] Better notification system
  - [x] Progress indicators

### Performance Optimizations

- [x] **Startup Time**
  - [x] Profile and optimize slow plugins
  - [x] Better lazy loading strategies
- [ ] **Memory Usage**
  - [ ] Monitor and optimize memory consumption
  - [ ] Garbage collection improvements
- [ ] **Caching**
  - [ ] Better caching strategies
  - [ ] Cache invalidation logic

## 🔨 Code Quality Improvements

### Documentation

- [ ] **Enhanced Luadocs**
  - [ ] Complete function documentation
  - [ ] Type annotations for all parameters
  - [ ] Return type documentation
- [ ] **User Guide**
  - [ ] Comprehensive setup guide
  - [ ] Customization examples
  - [ ] Troubleshooting section
- [ ] **API Documentation**
  - [ ] Public API reference
  - [ ] Plugin development guide

### Testing

- [ ] **Unit Tests**
  - [ ] Test core functionality
  - [ ] Test utility functions
- [ ] **Integration Tests**
  - [ ] Test plugin interactions
  - [ ] Test configuration loading
- [ ] **Health Checks**
  - [ ] Expand health check coverage
  - [ ] Performance health checks

### Error Handling

- [ ] **Graceful Degradation**
  - [ ] Handle missing dependencies
  - [ ] Fallback configurations
- [ ] **Better Error Messages**
  - [ ] User-friendly error reporting
  - [ ] Debugging information
