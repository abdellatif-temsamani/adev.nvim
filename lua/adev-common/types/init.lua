---@class SetupOpts - Adev setup options (default values shown)
---@field git string?  Path or command for Git executable (default: `"git"`)
---@field mapleader string? Leader key (default: `" "`)
---@field auto_update_check boolean?  Check for updates on startup [non-blocking] (default: `true`)
---@field lazy LazyOpts?  Lazy.Nvim package manager options
---@field lsp LspOpts?  LSP options
---@field ai_assistant AiAssistantOpts?  AI assistant options
---@field colorscheme string?  Theme to use (default: `"catppuccin"`) to use a custom theme, is must be installed first in `custom-plugins`
---@field catppuccin CatppuccinOpts?  catppuccin.nvim options
---@field ui UiOpts?  UI options
---@field flags AdevFlags feature flags

---@alias CatppuccinFlavor "macchiato" | "frappe" | "latte" | "mocha"
---@alias BorderStyle "double"|"single"|"shadow"|"rounded"|"solid"|"none"

---@class CatppuccinOpts
---@field enabled boolean?  Enable catppuccin (default: `true`)
---@field flavour CatppuccinFlavor?  catppuccin flavour (default: `"mocha"`)
---@field transparent boolean?  Enable transparent background (default: `false`)

---@class UiOpts
---@field border BorderStyle?  Border style (default: `"single"`)

---@class LazyOpts
---@field lazy_loading boolean?  lazy loading by default (default: `true`)
---@field plugin_version string?  default version of plugins (default: `nil`)
---@field auto_update_check boolean?  Check for plugin updates on startup (default: `true`)

---@class LspOpts
---@field enable boolean?  Enable LSP (default: `true`)

---@class AiAssistantOpts
---@field enabled boolean?  Enable AI assistance (default: `false`)
---@field plugin string?  AI assistant plugin to use (default: `"augmentcode/augment.vim"`)
---@field command string? AI assistant command to use (default: `"Augment"`)
---@field opts table?  AI assistant options (default: `nil`)
