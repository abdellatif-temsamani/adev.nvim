# Adev Files

A buffer-based file manager built into adev.nvim. Files and directories are represented as editable lines; operations are staged as pending ops and applied on `:write`.

## Architecture

```
lua/adev-files/
├── init.lua                    # Public API: open(), create_file(), rename_file(), delete_file()
├── state.lua                   # Per-buffer state management
├── clipboard.lua               # In-memory clipboard (copy/move items)
├── help.lua                    # In-buffer floating help window
├── netrw.lua                   # Directory-buffer interception and netrw replacement
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

## Configuration

```lua
require("adev-files").setup({
    replace_netrw = true, -- default
    open_files = {
        enabled = false,
        method = "edit", -- edit, split, vsplit, or tabedit
    },
})
```

With `replace_netrw = true`, opening a directory through `nvim .` or
`:edit path/to/directory` opens adev-files in the current window. Calling
`require("adev-files").open()` directly retains the floating-window interface.

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
| `model.original_by_id` | table<integer, AdevFilesNodeSnapshot> | Immutable identity and source path for each original entry |
| `confirming` | boolean | Whether a confirmation dialog owns the buffer |
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

Save or revert a pending rename before copying or cutting that entry. A mixed
selection containing a pending rename is rejected without changing the clipboard.
An earlier clipboard entry also cannot paste a source that is being renamed.

## Pending Ops Flow

1. Buffer is rendered from model (`core/view.lua`)
2. User edits lines (rename, add, delete) or uses clipboard/delete commands
3. Concealed IDs move with entry text; diffs compare those IDs with the immutable model snapshot
4. `sync/plan.lua` compiles one operation plan for labels, counts, change navigation, the changes window, and writes
5. On `:write`, `sync/apply.lua` executes all staged ops
6. Icons and pipe-delimited labels update in real time

Moving a line keeps its identity. A renamed entry retains its contents, and an
additional line with the same identity represents a copy. `<leader>nu` restores
the original name and identity, clearing the pending label. Whole-line edits
retain the identity captured by the buffer's edit notification.

Refresh and hidden-file toggles preserve unsaved changes and require saving or
discarding them before replacing the listing. Navigation asks before discarding
pending operations. Write confirmation locks editing until it is applied or
cancelled; a failed operation keeps the plan available for correction.
If the directory cannot be read after a successful save, editing pauses until a
refresh succeeds so saved operations cannot be applied again.

Names with whitespace, quotes, backslashes, or control characters use JSON string
escaping in the listing and decode to their exact filesystem names on save.

Git status is collected asynchronously using NUL-separated records. Filenames
are parsed without quoting ambiguity, conflicts are reported, directory labels
aggregate descendant status, and summary counts count changed files once.

## Highlight Groups

Defined in `syntax/adev_files.vim`:

| Group | Usage |
|-------|-------|
| `adevFilesPendingCopy` | `| copy |` label (DiffAdd bold) |
| `adevFilesPendingMove` | `| move |` label (DiffDelete bold) |
| `adevFilesPendingDelete` | `| delete |` label |
| `adevFilesPendingMark` | `●` selection mark (Special bold) |
