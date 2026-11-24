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
│   ├── op_validation.lua       # Structural validation shared by planner/executor
│   └── marks.lua               # Row-to-mark mapping for pending ops
│
├── events/
│   ├── keymaps.lua             # Buffer-local keymap bindings
│   ├── clipboard.lua           # Copy/cut/paste command handlers
│   ├── delete.lua              # Delete command handler
│   ├── revert.lua              # Revert line / undo staged ops
│   ├── selection.lua           # Entry collection (visual + mark-based)
│   ├── chmod.lua               # Permission change handler
│   ├── confirm.lua             # Confirm/cancel confirmation dialog
│   ├── navigation.lua          # Directory navigation (enter, parent, root)
│   ├── register.lua            # Buffer-local autocmd/keymap registration
│   └── validate.lua            # Destination validation for paste
│
├── file_manager/
│   ├── listing.lua             # Build editable listing lines from the filesystem
│   ├── render.lua              # Render lines, icons, labels and virtual text
│   ├── window.lua              # Floating window creation and title updates
│   ├── open.lua                # Open file manager for a directory
│   └── roots.lua               # Root directory normalization
│
├── sync/
│   ├── init.lua                # Re-exports plan/ops helpers
│   ├── view.lua                # Refresh, reset, toggle-hidden, set-root
│   ├── plan.lua                # Stage, unstage, and retrieve pending ops
│   ├── index.lua               # Snapshot original lines for diffing
│   ├── apply.lua               # Apply staged ops (write handler)
│   ├── attach.lua              # Buffer attachment and live edit tracking
│   ├── format.lua              # Confirmation popup text formatting
│   └── fs_ops.lua              # Re-exports filesystem helpers
│
├── parse/
│   ├── init.lua                # Re-exports line parsing helpers
│   ├── line.lua                # Line parsing: entry vs delete-marker
│   ├── trim.lua                # Concealed-ID and label trimming
│   └── validate.lua            # Re-exports path validation
│
├── utils/
│   ├── fs/
│   │   ├── path.lua            # Path utilities (join, abs, relpath, normalize)
│   │   ├── copy_file.lua       # File copy via libuv
│   │   ├── copy_dir.lua        # Recursive directory copy
│   │   ├── symlink.lua         # Symlink copy support
│   │   ├── mkdir.lua           # Recursive directory creation
│   │   ├── stat.lua            # stat/lstat/exists helpers
│   │   ├── uv.lua              # libuv shim
│   │   └── init.lua            # FS utility exports
│   └── confirmation.lua        # Confirmation dialog helper
│
├── icon/
│   ├── file.lua                # File icon by extension
│   └── directory.lua           # Directory icon
│
└── syntax/
    ├── adev_files.lua          # Buffer syntax highlighting
    ├── adev_files_help.lua     # Help window syntax highlighting
    ├── adev_files_confirm.lua  # Confirmation popup highlighting
    └── adev_changes.lua        # Changes popup highlighting
```

## Configuration

The plugin can be configured directly:

```lua
require("adev-files").setup({
    replace_netrw = true, -- default
    open_files = {
        enabled = false, -- file opening with <CR> is disabled by default
        method = "edit", -- edit, split, vsplit, or tabedit
    },
})
```

When used through a distribution that wraps plugins, pass the same table as
`core_plugins.adev_files.opts`; the wrapper forwards it to `setup()`. The
`open_files.enabled` flag controls whether `<CR>` opens a file at all. When it
is `false`, `<CR>` only navigates into directories; it does not auto-open files
on the cursor line.

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
| `selection_ids` | table<integer, true> | Entry IDs marked for batch operations |

## Keymaps

All file manager keymaps use `<leader>n` prefix. See `:help adev-files-keymaps`.

## Selection

Two modes:
- **Visual mode** — select a range, then use `<leader>ny`/`<leader>nx`/`<leader>nd`
- **Normal mode marks** — press `<TAB>` on each line to toggle a mark (`●` prefix), then use clipboard/delete commands on all marked entries

Both modes are accepted by permission changes: `<leader>nz` applies to the
current entry, marked entries, or a visual selection. Modes may be four-digit
octal (`4755`, including setuid/setgid/sticky) or symbolic (`rwxr-xr-x`).
Names and modes that cannot be parsed are reported without changing the
filesystem.

## Clipboard

A custom in-memory clipboard (`clipboard.lua`) stores `{mode: "copy"|"move", items: AdevFilesClipboardItem[]}`. Items are collected via `selection.lua` and applied on paste. A successful paste consumes the clipboard and clears selection marks; a rejected paste leaves it intact.

Copy and rename may be composed. A copied destination and its original can be renamed before saving, including a swap where the copied row takes the original name. A same-path copy is accepted only when a rename or move relocates the source in the same plan.

A pending move is stricter: its source cannot be renamed or deleted until the move is cancelled or its destination row is adjusted. Adding `#del` to a pasted destination, or deleting that row, cancels the paste.

After a successful write, clipboard entries that were not pasted are remapped through rename and move destinations and removed when their source was deleted.

Paste appends `_1`, `_2`, and so on when a name is occupied, including names marked for deletion. Renaming a newly created directory does not rewrite child rows entered under its old path; update those rows before saving.

## Pending Ops Flow

1. Buffer is rendered from model (`core/view.lua`)
2. User edits lines (rename, add, delete) or uses clipboard/delete commands
3. Concealed IDs move with entry text; diffs compare those IDs with the immutable model snapshot
4. `sync/plan.lua` compiles one operation plan for labels, counts, change navigation, the changes window, and writes
5. `core/op_validation.lua` rejects overlapping edits, duplicate/nested destinations, entry-kind changes, and directories pasted into themselves; the error is shown in the header and blocks writing
6. On `:write`, `sync/apply.lua` executes all staged ops and remaps clipboard sources after success
7. Icons and bracketed labels (`[copied from ...]`, `[moved from ...]`) update in real time

Moving a line keeps its identity. A renamed entry retains its contents, and an
additional line with the same identity represents a copy. A copied row may be
renamed independently, and a copy may reuse its source path when that source is
relocated by a rename or move in the same save. `<leader>nu` restores the
original name and identity, clearing the pending label. Whole-line edits retain
the identity captured by the buffer's edit notification.

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

Git is optional: if `vim.system` is unavailable, the configured executable is
missing, or a status call times out or fails, the manager shows one actionable
message and continues to browse and edit without status markers. Stale markers
are cleared rather than left visible from an earlier refresh. `:checkhealth
adev-files` reports the actual prerequisites (Neovim API, configured Git
executable and a usable temp directory).

Filesystem errors name the affected path and the underlying reason; an
unreadable root is reported instead of raising, and a partially applied write is
rolled back before the error is shown.

## Highlight Groups

Defined in `syntax/adev_files.lua` as default links; override any link in your
colorscheme if needed:

| Group | Usage |
|-------|-------|
| `adevFilesPendingCopy` | `[copied from ...]` label (links to `adevFilesGitCopied`) |
| `adevFilesPendingMove` | `[moved from ...]` label (links to `adevFilesGitModified`) |
| `adevFilesPendingNew` | `[new]` label (links to `adevFilesGitAdded`) |
| `adevFilesPendingRenamed` | `[renamed]` label (links to `adevFilesGitRenamed`) |
| `adevFilesPendingDelete` | `[deleted]` label (links to `adevFilesGitDeleted`) |
| `adevFilesPendingMark` | `●` selection mark (links to `Special`) |
| `adevFilesPlanError` | Invalid-line highlight (links to `DiagnosticError`) |
| `adevFilesGitModified` / `adevFilesGitAdded` / `adevFilesGitDeleted` / `adevFilesGitRenamed` / `adevFilesGitCopied` / `adevFilesGitUntracked` / `adevFilesGitConflict` | Git status markers |
