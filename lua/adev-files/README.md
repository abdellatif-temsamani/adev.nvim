# adev-files

A minimal file manager included with `adev.nvim`. It replaces netrw by default;
set `replace_netrw = false` to opt out.

## Features

- **Netrw replacement** — `nvim .` opens adev-files with a rich directory listing
- **Edit-in-place** — rename, add, or delete entries by editing buffer lines directly
- **Floating file manager** — open via `<leader>no`
- **Pending operations** — staged changes shown with virtual labels (`|copy|`, `|move|`, `|delete|`, `|new|`, `|renamed|`)
- **Multi-selection** — visual mode selection or TAB marks for batch operations
- **Clipboard** — copy/cut/paste files in-memory with visual labels
- **Git integration** — per-file git status indicators with color-coded suffixes
- **Toggle hidden files**
- **In-buffer help** — press `?` in an adev-files buffer
- **File creation/rename/deletion** — via `<leader>na`, `<leader>nr`, `<leader>nd`
- **Git commands** — `<leader>ns` for git status and commit --amend

## Configuration

```lua
{
  "adev-files",  -- loaded via adev core_plugins
  opts = {
    replace_netrw = true,       -- replace netrw as default directory browser
    open_files = {
      enabled = false,          -- auto-open files on cursor line
      method = "edit",          -- edit | split | vsplit | tabedit
    },
  },
}
```

## Keymaps (buffer-local)

| Key | Action |
|-----|--------|
| `<CR>` | Open file / enter directory |
| `-` | Go to parent directory |
| `u` | Go to root directory |
| `H` | Toggle hidden files |
| `r` | Refresh listing |
| `?` | Toggle help window |
| `dd` | Stage delete |
| `yy` | Copy file to clipboard |
| `Y` | Cut file to clipboard |
| `p` | Paste from clipboard |
| `d` | Paste destination label toggle |
| `R` | Revert staged operation on line |
| `<Esc>` | Clear selection / cancel |

## Commands

| Command | Action |
|---------|--------|
| `:AdevFiles` | Open file manager (falls back to cwd) |
| `:AdevFiles <path>` | Open file manager at `<path>` |
