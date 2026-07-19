# Adev Files

A buffer-based file manager built into adev.nvim. Files and directories are represented as editable lines; operations are staged as pending ops and applied on `:write`.

## Architecture

```
lua/adev-files/
├── init.lua                    # Public API: open(), create_file(), rename_file(), delete_file()
├── state.lua                   # Per-buffer state management
├── clipboard.lua               # In-memory clipboard (copy/move items)
├── help.lua                    # In-buffer floating help window
├── root.lua                    # Root directory resolution
├── validation.lua              # Input validation helpers
│
├── core/
│   ├── model.lua               # File-system model (scan, diff)
│   ├── view.lua                # Buffer projection (render lines from model)
│   ├── planner.lua             # Plan generation from buffer diffs
│   ├── executor.lua            # Execute staged ops on disk
│   └── marks.lua               # Row-to-mark mapping for pending ops
│
├── events/
│   ├── keymaps.lua             # Buffer-local keymap bindings
│   ├── clipboard.lua           # Copy/cut/paste command handlers
│   ├── delete.lua              # Delete command handler
│   ├── revert.lua              # Revert line / undo staged ops
│   ├── selection.lua           # Entry collection (visual + mark-based)
│   ├── confirm.lua             # Confirm/cancel confirmation dialog
│   ├── navigation.lua          # Directory navigation (enter, parent, root)
│   └── validate.lua            # Destination validation for paste
│
├── file_manager/
│   ├── listing.lua             # Buffer content rendering (header, rows, footer)
│   ├── render.lua              # Virtual text: icons, suffix labels, marks
│   ├── window.lua              # Floating window creation and title updates
│   ├── open.lua                # Open file manager for a directory
│   └── roots.lua               # Root directory normalization
│
├── sync/
│   ├── view.lua                # Refresh, reset, toggle-hidden, set-root
│   ├── plan.lua                # Stage, unstage, and retrieve pending ops
│   ├── index.lua               # Snapshot original lines for diffing
│   └── apply.lua               # Apply staged ops (write handler)
│
├── parse/
│   └── line.lua                # Line parsing: entry vs delete-marker
│
├── utils/
│   ├── fs/
│   │   ├── path.lua            # Path utilities (join, abs, relpath, normalize)
│   │   ├── copy_file.lua       # File copy via libuv
│   │   ├── copy_dir.lua        # Recursive directory copy
│   │   └── symlink.lua         # Symlink copy support
│   │   └── init.lua            # FS utility exports
│   └── confirmation.lua        # Confirmation dialog helper
│
├── icon/
│   ├── file.lua                # File icon by extension
│   └── directory.lua           # Directory icon
│
└── syntax/
    ├── adev_files.vim          # Buffer syntax highlighting
    └── adev_files_help.vim     # Help window syntax highlighting
```

## State

Per-buffer state (`state.lua`) holds:

| Field | Type | Description |
|-------|------|-------------|
| `root` | string | Current directory root |
| `model` | AdevFilesModel | File-system model (entries by kind) |
| `view` | AdevFilesProjection\|nil | Current buffer projection |
| `applying` | boolean | Whether ops are being applied |
| `pending_ops` | AdevFilesOp[] | Staged file operations |
| `original_lines` | table<integer, {entry, abs_path}> | Snapshot of original buffer lines |
| `show_hidden` | boolean | Show hidden files |
| `selection_marks` | table<integer, true> | Row→mark for multi-file selection |

## Keymaps

All file manager keymaps use `<leader>n` prefix. See `:help adev-files-keymaps`.

## Selection

Two modes:
- **Visual mode** — select a range, then use `<leader>ny`/`<leader>nx`/`<leader>nd`
- **Normal mode marks** — press `<TAB>` on each line to toggle a mark (`●` prefix), then use clipboard/delete commands on all marked entries

## Clipboard

A custom in-memory clipboard (`clipboard.lua`) stores `{mode: "copy"|"move", items: AdevFilesClipboardItem[]}`. Items are collected via `selection.lua` and applied on paste. Selection marks are cleared after paste.

## Pending Ops Flow

1. Buffer is rendered from model (`core/view.lua`)
2. User edits lines (rename, add, delete) or uses clipboard/delete commands
3. Diffs are computed against `original_lines` snapshot
4. Pending ops are staged via `sync/plan.lua`
5. On `:write`, `sync/apply.lua` executes all staged ops
6. Icons and pipe-delimited labels update in real time

## Highlight Groups

Defined in `syntax/adev_files.vim`:

| Group | Usage |
|-------|-------|
| `adevFilesPendingCopy` | `| copy |` label (DiffAdd bold) |
| `adevFilesPendingMove` | `| move |` label (DiffDelete bold) |
| `adevFilesPendingDelete` | `| delete |` label |
| `adevFilesPendingMark` | `●` selection mark (Special bold) |
