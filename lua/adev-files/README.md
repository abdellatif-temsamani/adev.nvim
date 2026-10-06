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
- **Pending changes** — `<leader>ns` to inspect staged filesystem operations
- **Permissions** — `<leader>nz` to change permissions on current or marked entries

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
| `<CR>` / `L` / `<Right>` | Open file / enter directory |
| `<BS>` / `H` / `<Left>` | Go to parent directory |
| `=` | Go to initial root directory |
| `<leader>nq` | Quit |
| `q` | Close floating file manager |
| `<leader>nh` | Toggle hidden files |
| `<Tab>` | Toggle mark on current line |
| `<leader>nm` | Clear all marks |
| `v` / `V` / `<C-v>` | Character / line / block selection |
| `<leader>ny` | Copy current, marked, or visually selected entries |
| `<leader>nx` | Cut current, marked, or visually selected entries |
| `<leader>np` | Paste into current directory |
| `<leader>bs` / `:write` | Apply staged changes |
| `<leader>nu` | Revert current line |
| `<leader>nc` | Reset all (discard changes) |
| `<leader>nj` | Jump to next changed entry |
| `<leader>nk` | Jump to previous changed entry |
| `<leader>ns` | View pending changes |
| `<leader>nd` | Stage delete of current, marked, or visually selected entries |
| `<leader>nz` | Change permissions of current or marked entries |
| `?` | Open help menu |

Edit entry names to rename them, or add lines to create files and directories.
Permissions accept octal (`755`) or symbolic (`rwxr-xr-x`) input and apply
immediately, without `:write`.

In help and pending changes popups, use `j` / `k` / `<C-d>` / `<C-u>` to scroll
and `q` / `<Esc>` to close. In confirmation popups, `y` / `<CR>` confirms and
`n` / `q` / `<Esc>` cancels. The permissions guide also supports `q` when focused.

Inside the file manager, `u`, `<C-r>`, `K`, `J`, `dd`, `yy`, `D`, and
`<leader>bq` are disabled. Use the mappings above for reverting, deleting,
copying, and quitting.

## Global keymaps (outside file manager)

| Key | Action |
|-----|--------|
| `<leader>no` | Open file manager |
| `<leader>na` | Create file / directory (prompt) |
| `<leader>nr` | Rename current file (prompt) |
| `<leader>nd` | Delete current file (confirm) |

`<leader>no`, `<leader>na`, and `<leader>nr` are disabled inside the file manager.

## Commands

| Command | Action |
|---------|--------|
| `:AdevFiles` | Open file manager (falls back to cwd) |
| `:AdevFiles <path>` | Open file manager at `<path>` |
