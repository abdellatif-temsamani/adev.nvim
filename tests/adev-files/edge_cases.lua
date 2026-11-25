-- Headless edge-case regression tests for adev-files change tracking.
--
-- Run from the repository root:
--   nvim --headless -u NONE -l tests/adev-files/edge_cases.lua

local source = debug.getinfo(1, "S").source
local script = source:sub(1, 1) == "@" and source:sub(2) or source
local root = vim.fn.fnamemodify(script, ":p:h:h:h")
vim.opt.rtp:append(root)

local attach = require "adev-files.sync.attach"
local chmod = require "adev-files.events.chmod"
local clipboard = require "adev-files.clipboard"
local clipboard_events = require "adev-files.events.clipboard"
local confirm_events = require "adev-files.events.confirm"
local confirmation = require "adev-files.utils.confirmation"
local delete_events = require "adev-files.events.delete"
local executor = require "adev-files.core.executor"
local format = require "adev-files.sync.format"
local git = require "adev-files.git"
local listing = require "adev-files.file_manager.listing"
local navigation = require "adev-files.events.navigation"
local open = require "adev-files.file_manager.open"
local path_validation = require "adev-files.validation"
local plan = require "adev-files.sync.plan"
local render = require "adev-files.file_manager.render"
local revert = require "adev-files.events.revert"
local root = require "adev-files.root"
local selection = require "adev-files.events.selection"
local state = require "adev-files.state"
local sync_view = require "adev-files.sync.view"
local utils = require "adev-common.utils"
local validation = require "adev-files.core.op_validation"
local view = require "adev-files.core.view"
local window = require "adev-files.file_manager.window"

local TEST_ROOT = "/tmp/opencode/adev-files-tests"
local uv = vim.uv or vim.loop
local failures = 0

local function fail(message)
    failures = failures + 1
    io.write("FAIL: ", message, "\n")
end

local function check(condition, message)
    if not condition then
        fail(message)
    end
end

local function eq(actual, expected, message)
    if actual ~= expected then
        fail(
            string.format("%s (expected %q, got %q)", message, tostring(expected), tostring(actual))
        )
    end
end

local function reset_dir(name)
    local dir = TEST_ROOT .. "/" .. name
    vim.fn.delete(dir, "rf")
    vim.fn.mkdir(dir, "p")
    return dir
end

local function write_file(path, text)
    local parent = vim.fn.fnamemodify(path, ":h")
    vim.fn.mkdir(parent, "p")
    vim.fn.writefile(vim.split(text, "\n", { plain = true }), path)
end

local function read_file(path)
    return table.concat(vim.fn.readfile(path), "\n")
end

local function new_manager(dir)
    vim.cmd "silent! %bwipeout!"
    local buf = vim.api.nvim_get_current_buf()
    local opened = open.open(dir, { mode = "current" })
    check(opened == buf, "open returned a different buffer")
    return buf
end

local function lines(buf)
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

local function row_with(buf, text)
    for i, line in ipairs(lines(buf)) do
        if line:find(text, 1, true) then
            return i - 1
        end
    end
    return nil
end

local function set_row(buf, row, text)
    vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { text })
end

local function cursor_row(buf, text)
    local row = row_with(buf, text)
    assert(row, "row not found: " .. text)
    vim.api.nvim_set_current_buf(buf)
    vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
    return row
end

local function header_error_text(buf)
    local marks = vim.api.nvim_buf_get_extmarks(buf, state.display_ns(), 0, 0, { details = true })
    local chunks = {}
    for _, mark in ipairs(marks) do
        for _, virt_line in ipairs(mark[4].virt_lines or {}) do
            for _, chunk in ipairs(virt_line) do
                table.insert(chunks, chunk[1])
            end
        end
    end
    return table.concat(chunks, "")
end

local function buffer_virt_text(buf)
    local marks = vim.api.nvim_buf_get_extmarks(buf, state.display_ns(), 0, -1, { details = true })
    local chunks = {}
    for _, mark in ipairs(marks) do
        for _, chunk in ipairs(mark[4].virt_text or {}) do
            table.insert(chunks, chunk[1])
        end
    end
    return table.concat(chunks, "")
end

local function plan_error_highlight_rows(buf)
    local marks = vim.api.nvim_buf_get_extmarks(buf, state.display_ns(), 0, -1, { details = true })
    local rows = {}
    for _, mark in ipairs(marks) do
        if mark[4].hl_group == "adevFilesPlanError" then
            table.insert(rows, mark[2])
        end
    end
    table.sort(rows)
    return rows
end

local function row_set(rows)
    local set = {}
    for _, row in ipairs(rows or {}) do
        set[row] = true
    end
    return set
end

local function has_op(ops, kind, src, dst, path)
    for _, op in ipairs(ops or {}) do
        if
            op.type == kind
            and (src == nil or op.src == src)
            and (dst == nil or op.dst == dst)
            and (path == nil or op.path == path)
        then
            return true
        end
    end
    return false
end

local function test_copy_then_swap_rename()
    local dir = reset_dir "copy-swap"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "copy")
    clipboard_events.paste(buf, "")

    local pasted = row_with(buf, "A_1.txt")
    check(pasted ~= nil, "copy+paste should create A_1.txt row")
    eq(clipboard.get(), nil, "paste should consume the clipboard")
    set_row(buf, row_with(buf, "A.txt"), "A_old.txt")
    set_row(buf, pasted, "A.txt")

    local ops, err = plan.plan_ops(buf)
    if not ops then
        fail("copy+swap plan failed: " .. tostring(err))
        return
    end
    check(
        has_op(ops, "copy", dir .. "/A.txt", dir .. "/A.txt"),
        "plan should contain same-path copy"
    )
    check(has_op(ops, "rename", dir .. "/A.txt", dir .. "/A_old.txt"), "plan should contain rename")

    local ok, apply_err = executor.apply_ops(ops)
    check(ok, "copy+swap apply failed: " .. tostring(apply_err))
    eq(read_file(dir .. "/A_old.txt"), "alpha", "renamed original content")
    eq(read_file(dir .. "/A.txt"), "alpha", "same-path copy content")
end

local function test_paste_consumes_clipboard()
    local dir = reset_dir "paste-clears-clipboard"
    write_file(dir .. "/A.txt", "alpha")
    write_file(dir .. "/B.txt", "beta")
    vim.fn.mkdir(dir .. "/dest", "p")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "copy")
    check(buffer_virt_text(buf):find("[copied]", 1, true) ~= nil, "copy marker before paste")
    clipboard_events.paste(buf, "")
    eq(clipboard.get(), nil, "copy+paste should clear the clipboard")
    check(buffer_virt_text(buf):find("[copied]", 1, true) == nil, "copy marker after paste")
    check(
        buffer_virt_text(buf):find("[copied from", 1, true) ~= nil,
        "pasted row should keep its pending copy marker"
    )

    cursor_row(buf, "B.txt")
    clipboard_events.set_clipboard(buf, "move")
    clipboard_events.paste(buf, "dest")
    eq(clipboard.get(), nil, "cut+paste should clear the clipboard")
end

local function test_failed_paste_keeps_clipboard()
    local dir = reset_dir "paste-failure-clipboard"
    vim.fn.mkdir(dir .. "/sub", "p")
    write_file(dir .. "/sub/file.txt", "alpha")
    local buf = new_manager(dir)

    cursor_row(buf, "sub/")
    clipboard_events.set_clipboard(buf, "copy")
    clipboard_events.paste(buf, "sub")
    check(clipboard.get() ~= nil, "a rejected paste must not clear the clipboard")
    clipboard.clear()
end

local function test_copy_with_pending_rename()
    local dir = reset_dir "copy-rename"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    set_row(buf, row_with(buf, "A.txt"), "Renamed.txt")

    cursor_row(buf, "Renamed.txt")
    clipboard_events.set_clipboard(buf, "copy")
    local before = #lines(buf)
    clipboard_events.paste(buf, "")
    check(#lines(buf) == before + 1, "copy paste should not be blocked by pending rename")

    local ops, err = plan.plan_ops(buf)
    if not ops then
        fail("copy with pending rename plan failed: " .. tostring(err))
        return
    end
    check(
        has_op(ops, "rename", dir .. "/A.txt", dir .. "/Renamed.txt"),
        "pending rename should be planned"
    )
    check(has_op(ops, "copy", dir .. "/A.txt", dir .. "/A_1.txt"), "copy should be planned")

    local ok, apply_err = executor.apply_ops(ops)
    check(ok, "copy with pending rename apply failed: " .. tostring(apply_err))
    eq(read_file(dir .. "/Renamed.txt"), "alpha", "renamed source content")
    eq(read_file(dir .. "/A_1.txt"), "alpha", "copied content")
end

local function test_move_source_rename_rejected()
    local dir = reset_dir "move-rename"
    write_file(dir .. "/A.txt", "alpha")
    vim.fn.mkdir(dir .. "/sub", "p")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "move")
    clipboard_events.paste(buf, "sub")
    set_row(buf, row_with(buf, "A.txt"), "Renamed.txt")

    local ops, err = plan.plan_ops(buf)
    check(ops == nil, "renaming pending move source should fail the plan")
    check(
        err and err:find("cannot rename the source of a pending move", 1, true) ~= nil,
        "move source rename error message: " .. tostring(err)
    )

    render.add_virtual_text(buf, dir)
    local highlighted = row_set(plan_error_highlight_rows(buf))
    local source_row = row_with(buf, "Renamed.txt")
    check(source_row ~= nil, "renamed move source row should still be visible")
    check(highlighted[source_row], "move source conflict row should be highlighted")
    check(
        header_error_text(buf):find("(rows ", 1, true) ~= nil,
        "header should list rows for a move source conflict"
    )
end

local function test_duplicate_id_recovery()
    local dir = reset_dir "id-recovery"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    local original = lines(buf)[2]
    set_row(buf, 1, original:gsub("A.txt", "B.txt", 1))
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "A.txt" })

    local ops, err = plan.plan_ops(buf)
    if not ops then
        fail("duplicate ID plan failed: " .. tostring(err))
        return
    end
    check(has_op(ops, "rename", dir .. "/A.txt", dir .. "/B.txt"), "B.txt should be a rename")
    check(has_op(ops, "create", nil, nil, dir .. "/A.txt"), "new A.txt should be a create")
    check(not has_op(ops, "copy"), "path recovery must not turn the new row into a copy")

    local entries = view.parse_buffer(buf)
    local ids = {}
    for _, item in ipairs(entries) do
        if item.entry.id then
            ids[item.entry.id] = (ids[item.entry.id] or 0) + 1
        end
    end
    for id, count in pairs(ids) do
        check(count == 1, "duplicate entry ID " .. tostring(id))
    end
end

local function test_delete_pasted_row_cancels_pending()
    local dir = reset_dir "delete-destination"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "copy")
    clipboard_events.paste(buf, "")
    cursor_row(buf, "A_1.txt")
    delete_events.delete_selected(buf)

    eq(row_with(buf, "A_1.txt"), nil, "pasted row should be removed")
    eq(#state.get_pending_ops(buf), 0, "deleting pasted row should cancel pending op")
    local ops = plan.plan_ops(buf)
    eq(#(ops or {}), 0, "no filesystem ops after canceled paste")
end

local function test_delete_classifies_before_cancelling_pending()
    local dir = reset_dir "delete-classify-order"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "copy")
    clipboard_events.paste(buf, "")

    local original_plan = plan.plan_ops
    local pending_at_plan = nil
    plan.plan_ops = function(plan_buf)
        if pending_at_plan == nil then
            pending_at_plan = #state.get_pending_ops(plan_buf)
        end
        return original_plan(plan_buf)
    end
    cursor_row(buf, "A_1.txt")
    delete_events.delete_selected(buf)
    plan.plan_ops = original_plan

    eq(pending_at_plan, 1, "delete must classify before cancelling the pending paste")
    eq(#state.get_pending_ops(buf), 0, "deleting pasted row should cancel pending op")
end

local function test_delete_failed_plan_does_not_stage_original()
    local dir = reset_dir "delete-failed-plan"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "copy")
    clipboard_events.paste(buf, "")
    local pasted = row_with(buf, "A_1.txt")
    local pasted_line = lines(buf)[pasted + 1]
    local duplicate_line = pasted_line:gsub("A_1.txt", "A_2.txt", 1)
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { duplicate_line })

    cursor_row(buf, "A.txt")
    delete_events.delete_selected(buf)

    check(
        not has_op(state.get_pending_ops(buf), "delete", nil, nil, dir .. "/A.txt"),
        "failed plan must not stage deletion of the original file"
    )
end

local function test_delete_marker_cancels_pending()
    local dir = reset_dir "delete-marker-destination"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "copy")
    clipboard_events.paste(buf, "")
    local pasted = row_with(buf, "A_1.txt")
    set_row(buf, pasted, lines(buf)[pasted + 1] .. "  #del")

    local ops, err = plan.plan_ops(buf)
    check(ops ~= nil, "deleted pending destination should not plan-error: " .. tostring(err))
    eq(#(ops or {}), 0, "#del should cancel pasted destination")
    eq(#state.get_pending_ops(buf), 0, "#del should clear pending op")
end

local function test_kind_change_rejected()
    local dir = reset_dir "kind-change"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "copy")
    clipboard_events.paste(buf, "")
    local pasted = row_with(buf, "A_1.txt")
    set_row(buf, pasted, lines(buf)[pasted + 1] .. "/")

    local ops, err = plan.plan_ops(buf)
    check(ops == nil, "changing pasted entry type should fail")
    check(
        err and err:find("cannot change the entry type", 1, true) ~= nil,
        "kind change error message: " .. tostring(err)
    )
end

local function test_directory_into_itself()
    local dir = reset_dir "directory-into-itself"
    vim.fn.mkdir(dir .. "/sub", "p")
    write_file(dir .. "/sub/file.txt", "alpha")
    local buf = new_manager(dir)

    local original_err_notify = utils.err_notify
    local message = nil
    utils.err_notify = function(msg)
        message = msg
    end
    cursor_row(buf, "sub/")
    clipboard_events.set_clipboard(buf, "copy")
    local before = #lines(buf)
    clipboard_events.paste(buf, "sub")
    utils.err_notify = original_err_notify

    check(#lines(buf) == before, "failed paste must not modify the buffer")
    check(
        message and message:find("cannot paste a directory into itself", 1, true) ~= nil,
        "directory self-containment error: " .. tostring(message)
    )
end

local function test_same_path_copy_with_delete_rejected()
    local dir = reset_dir "copy-delete"
    write_file(dir .. "/A.txt", "alpha")
    local _, err = validation.validate_structural {
        { type = "copy", src = dir .. "/A.txt", dst = dir .. "/A.txt", kind = "file" },
        { type = "delete", path = dir .. "/A.txt", kind = "file" },
    }
    check(
        err and err:find("identical source and destination", 1, true) ~= nil,
        "same-path copy without relocation must be rejected: " .. tostring(err)
    )
end

local function test_clipboard_path_changes()
    local dir = reset_dir "clipboard-paths"
    write_file(dir .. "/A.txt", "alpha")
    write_file(dir .. "/C.txt", "c")
    clipboard.set("copy", {
        { kind = "file", src = dir .. "/A.txt" },
        { kind = "file", src = dir .. "/C.txt" },
        { kind = "file", src = dir .. "/C.txt" },
    })
    clipboard.apply_path_changes {
        { type = "rename", src = dir .. "/A.txt", dst = dir .. "/B.txt", kind = "file" },
        { type = "delete", path = dir .. "/C.txt", kind = "file" },
    }
    local clip = clipboard.get()
    check(clip and clip.items and #clip.items == 1, "clipboard should keep one remapped entry")
    if clip and clip.items[1] then
        eq(clip.items[1].src, dir .. "/B.txt", "clipboard remap path")
    end
    clipboard.clear()
end

local function test_directory_rename_remaps_clipboard_child()
    local dir = reset_dir "clipboard-directory"
    local child = dir .. "/old/sub/file.txt"
    write_file(child, "alpha")
    clipboard.set("copy", { { kind = "file", src = child } })
    clipboard.apply_path_changes {
        { type = "rename", src = dir .. "/old", dst = dir .. "/new", kind = "directory" },
    }
    local clip = clipboard.get()
    check(
        clip and clip.items and #clip.items == 1,
        "clipboard child should survive directory rename"
    )
    if clip and clip.items[1] then
        eq(clip.items[1].src, dir .. "/new/sub/file.txt", "clipboard child path remap")
    end
    clipboard.clear()
end

local function test_move_destination_rename()
    local dir = reset_dir "move-destination-rename"
    write_file(dir .. "/A.txt", "alpha")
    vim.fn.mkdir(dir .. "/sub", "p")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "move")
    clipboard_events.paste(buf, "sub")
    set_row(buf, row_with(buf, "sub/A.txt"), "sub/Renamed.txt")

    local ops, err = plan.plan_ops(buf)
    if not ops then
        fail("move destination rename plan failed: " .. tostring(err))
        return
    end
    check(
        has_op(ops, "move", dir .. "/A.txt", dir .. "/sub/Renamed.txt"),
        "move destination should follow the renamed row"
    )
    check(
        not has_op(ops, "move", dir .. "/A.txt", dir .. "/sub/A.txt"),
        "old move destination should be gone"
    )

    local ok, apply_err = executor.apply_ops(ops)
    check(ok, "move destination rename apply failed: " .. tostring(apply_err))
    eq(read_file(dir .. "/sub/Renamed.txt"), "alpha", "moved content")
    check(vim.fn.filereadable(dir .. "/A.txt") == 0, "move source should be gone")
end

local function test_whole_line_edit_preserves_identity()
    local dir = reset_dir "whole-line-edit"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    -- Simulate a whole-line replacement that drops the concealed ID.
    set_row(buf, row_with(buf, "A.txt"), "A.txt")
    local ops, err = plan.plan_ops(buf)
    check(ops ~= nil, "whole-line edit plan failed: " .. tostring(err))
    eq(#(ops or {}), 0, "unchanged name should not create filesystem ops")
    check(lines(buf)[2]:find("^/%d+ ", 1) ~= nil, "path recovery should restore an original ID")
end

local function test_delete_move_source_rejected()
    local dir = reset_dir "delete-move-source"
    write_file(dir .. "/A.txt", "alpha")
    vim.fn.mkdir(dir .. "/sub", "p")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "move")
    clipboard_events.paste(buf, "sub")

    local original_err_notify = utils.err_notify
    local message = nil
    utils.err_notify = function(msg)
        message = msg
    end
    cursor_row(buf, "A.txt")
    delete_events.delete_selected(buf)
    utils.err_notify = original_err_notify

    check(
        message
            and message:find("Cancel the pending move before deleting its source", 1, true)
                ~= nil,
        "delete move source error: " .. tostring(message)
    )
    check(row_with(buf, "A.txt") ~= nil, "move source row should remain")
    eq(#state.get_pending_ops(buf), 1, "move should remain pending")
end

local function test_delete_pending_copy_source()
    local dir = reset_dir "delete-copy-source"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "copy")
    clipboard_events.paste(buf, "")
    cursor_row(buf, "A.txt")
    delete_events.delete_selected(buf)

    local ops, err = plan.plan_ops(buf)
    if not ops then
        fail("delete copy source plan failed: " .. tostring(err))
        return
    end
    check(has_op(ops, "delete", nil, nil, dir .. "/A.txt"), "source delete should be planned")
    check(
        has_op(ops, "copy", dir .. "/A.txt", dir .. "/A_1.txt"),
        "copy should survive source delete"
    )

    local ok, apply_err = executor.apply_ops(ops)
    check(ok, "delete copy source apply failed: " .. tostring(apply_err))
    check(vim.fn.filereadable(dir .. "/A.txt") == 0, "source should be deleted")
    eq(read_file(dir .. "/A_1.txt"), "alpha", "copy content should survive")
end

local function test_move_plus_same_path_copy()
    local dir = reset_dir "move-copy-same-path"
    write_file(dir .. "/A.txt", "alpha")
    vim.fn.mkdir(dir .. "/sub", "p")
    local ok, err = executor.apply_ops {
        { type = "move", src = dir .. "/A.txt", dst = dir .. "/sub/A.txt", kind = "file" },
        { type = "copy", src = dir .. "/A.txt", dst = dir .. "/A.txt", kind = "file" },
    }
    check(ok, "move + same-path copy failed: " .. tostring(err))
    eq(read_file(dir .. "/A.txt"), "alpha", "copy at original path")
    eq(read_file(dir .. "/sub/A.txt"), "alpha", "moved original")
end

local function test_duplicate_destination_rejected()
    local dir = reset_dir "duplicate-destination"
    write_file(dir .. "/A.txt", "alpha")
    write_file(dir .. "/B.txt", "beta")
    local _, err = validation.validate_structural {
        { type = "rename", src = dir .. "/A.txt", dst = dir .. "/C.txt", kind = "file" },
        { type = "copy", src = dir .. "/B.txt", dst = dir .. "/C.txt", kind = "file" },
    }
    check(
        err and err:find("same destination", 1, true) ~= nil,
        "duplicate destination should be rejected: " .. tostring(err)
    )
end

local function test_directory_rename_then_create_inside()
    local dir = reset_dir "rename-dir-create-inside"
    vim.fn.mkdir(dir .. "/old", "p")
    local _, err = validation.validate_structural {
        { type = "rename", src = dir .. "/old", dst = dir .. "/new", kind = "directory" },
        { type = "create", path = dir .. "/new/file.txt", kind = "file" },
    }
    check(err == nil, "creating inside a renamed directory should be valid: " .. tostring(err))
end

local function test_malformed_staged_op_rejected_before_abs()
    local dir = reset_dir "malformed-staged"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)
    plan.stage_ops(buf, {
        { type = "copy", dst = dir .. "/B.txt", kind = "file" },
    })
    local ops, err = plan.plan_ops(buf)
    check(ops == nil, "staged copy without src must not reach path.abs")
    check(err and err:find("missing src", 1, true) ~= nil, "missing src error: " .. tostring(err))
end

local function test_staged_op_without_dst_id_runs_once()
    local dir = reset_dir "staged-one-shot"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)
    plan.stage_ops(buf, {
        { type = "copy", src = dir .. "/A.txt", dst = dir .. "/B.txt", kind = "file" },
    })

    local first = plan.plan_ops(buf)
    check(
        has_op(first, "copy", dir .. "/A.txt", dir .. "/B.txt"),
        "one-shot staged copy should be planned once"
    )
    local second = plan.plan_ops(buf)
    check(
        not has_op(second, "copy", dir .. "/A.txt", dir .. "/B.txt"),
        "one-shot staged copy must not be regenerated on the next plan"
    )
end

local function test_relative_symlink_copy_is_rebased()
    local uv = vim.uv or vim.loop
    local fs = require "adev-files.utils.fs"
    local dir = reset_dir "symlink-rebase"
    local src_dir = dir .. "/src"
    local dst_dir = dir .. "/dst"
    vim.fn.mkdir(src_dir .. "/sub", "p")
    vim.fn.mkdir(dst_dir, "p")
    write_file(src_dir .. "/target.txt", "alpha")
    uv.fs_symlink("../target.txt", src_dir .. "/sub/link.txt")

    local ok, err = fs.copy_dir_recursive(src_dir, dst_dir .. "/copy")
    check(ok, "copy_dir_recursive with a relative symlink failed: " .. tostring(err))
    eq(
        table.concat(vim.fn.readfile(dst_dir .. "/copy/sub/link.txt"), "\n"),
        "alpha",
        "copied relative symlink should resolve against its new directory"
    )
end

local function test_cross_device_move_remaps_internal_symlink()
    local dir = reset_dir "symlink-move"
    local src = dir .. "/src"
    local dst = dir .. "/dst"
    vim.fn.mkdir(src .. "/sub", "p")
    write_file(src .. "/target.txt", "alpha")
    write_file(src .. "/absolute.txt", "beta")
    uv.fs_symlink("../target.txt", src .. "/sub/link.txt")
    uv.fs_symlink(src .. "/absolute.txt", src .. "/sub/absolute-link.txt")

    local real_rename = uv.fs_rename
    uv.fs_rename = function(old, new)
        if new == dst then
            return false, "EXDEV", "cross-device link"
        end
        return real_rename(old, new)
    end
    local ok, err = executor.apply_ops {
        { type = "move", src = src, dst = dst, kind = "directory" },
    }
    uv.fs_rename = real_rename

    check(ok, "cross-device directory move failed: " .. tostring(err))
    local target = uv.fs_readlink(dst .. "/sub/link.txt")
    eq(target or "", "../target.txt", "moved symlink should target the destination tree")
    eq(read_file(dst .. "/sub/link.txt"), "alpha", "moved symlink contents should resolve")
    eq(
        uv.fs_readlink(dst .. "/sub/absolute-link.txt") or "",
        "../absolute.txt",
        "moved absolute symlink should target the destination tree"
    )
    eq(read_file(dst .. "/sub/absolute-link.txt"), "beta", "moved absolute symlink should resolve")
end

local function test_cross_device_move_preserves_top_level_symlink()
    local dir = reset_dir "symlink-move-top-level"
    write_file(dir .. "/target.txt", "alpha")
    uv.fs_symlink("target.txt", dir .. "/link.txt")

    local dst = dir .. "/moved-link.txt"
    local real_rename = uv.fs_rename
    uv.fs_rename = function(old, new)
        if new == dst then
            return false, "EXDEV", "cross-device link"
        end
        return real_rename(old, new)
    end
    local ok, err = executor.apply_ops {
        { type = "move", src = dir .. "/link.txt", dst = dst },
    }
    uv.fs_rename = real_rename

    check(ok, "cross-device top-level symlink move failed: " .. tostring(err))
    local st = uv.fs_lstat(dst)
    check(st ~= nil and st.type == "link", "moved top-level symlink should remain a link")
    eq(uv.fs_readlink(dst) or "", "target.txt", "moved top-level symlink target")
    eq(read_file(dst), "alpha", "moved top-level symlink should resolve")
end

local function test_cross_device_move_resolves_symlinked_source_parent()
    local dir = reset_dir "symlink-move-physical-parent"
    local real = dir .. "/real"
    local deep = real .. "/deep"
    local alias = dir .. "/alias"
    vim.fn.mkdir(deep .. "/src/sub", "p")
    uv.fs_symlink(deep, alias)
    write_file(deep .. "/src/target.txt", "alpha")
    write_file(deep .. "/outside.txt", "outside")
    write_file(deep .. "/src/absolute.txt", "beta")
    uv.fs_symlink("target.txt", alias .. "/src/plain-link.txt")
    uv.fs_symlink("../target.txt", alias .. "/src/sub/internal-link.txt")
    uv.fs_symlink("../../outside.txt", alias .. "/src/sub/outside-link.txt")
    uv.fs_symlink(alias .. "/src/absolute.txt", alias .. "/src/sub/absolute-link.txt")

    local dst = dir .. "/dst"
    local real_rename = uv.fs_rename
    uv.fs_rename = function(old, new)
        if new == dst then
            return false, "EXDEV", "cross-device link"
        end
        return real_rename(old, new)
    end
    local ok, err = executor.apply_ops {
        { type = "move", src = alias .. "/src", dst = dst, kind = "directory" },
    }
    uv.fs_rename = real_rename

    check(ok, "cross-device move via symlinked parent failed: " .. tostring(err))
    local function read_if_exists(file)
        if not uv.fs_stat(file) then
            return "<missing>"
        end
        return read_file(file)
    end
    eq(
        read_if_exists(dst .. "/plain-link.txt"),
        "alpha",
        "moved plain relative symlink should be remapped through the source root"
    )
    eq(
        read_if_exists(dst .. "/sub/internal-link.txt"),
        "alpha",
        "moved internal symlink should resolve in the destination tree"
    )
    eq(
        read_if_exists(dst .. "/sub/outside-link.txt"),
        "outside",
        "moved symlink should resolve from the source link's physical directory"
    )
    eq(
        read_if_exists(dst .. "/sub/absolute-link.txt"),
        "beta",
        "moved absolute symlink should still map through the original root"
    )
end

local function test_symlink_to_directory_copies_contents()
    local uv = vim.uv or vim.loop
    local dir = reset_dir "symlink-dir-copy"
    vim.fn.mkdir(dir .. "/real", "p")
    write_file(dir .. "/real/file.txt", "alpha")
    uv.fs_symlink("real", dir .. "/alias")

    local buf = new_manager(dir)
    check(row_with(buf, "alias/") ~= nil, "symlink to a directory should be listed as a directory")

    local ok, err = executor.apply_ops {
        { type = "copy", src = dir .. "/alias", dst = dir .. "/alias-copy", kind = "directory" },
    }
    check(ok, "copying a symlink listed as a directory failed: " .. tostring(err))
    eq(read_file(dir .. "/alias-copy/file.txt"), "alpha", "symlinked directory contents copied")
end

local function test_nested_destination_rejected()
    local dir = reset_dir "nested-destination"
    write_file(dir .. "/A.txt", "alpha")
    write_file(dir .. "/B.txt", "beta")
    local _, err = validation.validate_structural {
        { type = "rename", src = dir .. "/A.txt", dst = dir .. "/sub", kind = "file" },
        { type = "rename", src = dir .. "/B.txt", dst = dir .. "/sub/B.txt", kind = "file" },
    }
    check(
        err and err:find("nested destinations", 1, true) ~= nil,
        "nested destination should be rejected: " .. tostring(err)
    )
end

local function test_plan_error_highlights_duplicate_path()
    local dir = reset_dir "plan-error-highlight-duplicate"
    write_file(dir .. "/A.txt", "alpha")
    write_file(dir .. "/B.txt", "beta")
    local buf = new_manager(dir)

    local a_row = row_with(buf, "A.txt")
    local b_row = row_with(buf, "B.txt")
    check(a_row ~= nil and b_row ~= nil, "duplicate path test needs both rows")
    if not a_row or not b_row then
        return
    end
    local original_b = lines(buf)[b_row + 1]
    set_row(buf, b_row, (original_b:gsub("B.txt", "A.txt", 1)))

    render.add_virtual_text(buf, dir)
    local st = state.get(buf)
    check(
        st.plan_error and st.plan_error:find("duplicate path", 1, true) ~= nil,
        "duplicate path should still fail the plan: " .. tostring(st.plan_error)
    )
    local error_rows = st.plan_error_rows or {}
    local reported = row_set(error_rows)
    check(reported[a_row] and reported[b_row], "both duplicate rows should be reported")
    local numbered = {}
    for _, row in ipairs(error_rows) do
        table.insert(numbered, tostring(row + 1))
    end
    check(
        header_error_text(buf):find("(rows " .. table.concat(numbered, ", ") .. ")", 1, true) ~= nil,
        "header should list every conflicting row"
    )
    local highlighted = row_set(plan_error_highlight_rows(buf))
    check(highlighted[a_row] and highlighted[b_row], "both duplicate rows should be highlighted")

    set_row(buf, b_row, original_b)
    render.add_virtual_text(buf, dir)
    st = state.get(buf)
    check(st.plan_error == nil, "fixing the duplicate path should clear the plan error")
    eq(#(st.plan_error_rows or {}), 0, "fixing the duplicate path should clear error rows")
    eq(#plan_error_highlight_rows(buf), 0, "fixing the duplicate path should clear highlights")
    check(
        header_error_text(buf):find("(rows ", 1, true) == nil,
        "fixing the duplicate path should clear header rows"
    )
end

local function virt_text_for_row(buf, row)
    local marks = vim.api.nvim_buf_get_extmarks(
        buf,
        state.display_ns(),
        { row, 0 },
        { row, -1 },
        { details = true }
    )
    local parts = {}
    for _, mark in ipairs(marks) do
        for _, chunk in ipairs(mark[4].virt_text or {}) do
            table.insert(parts, chunk[1])
        end
    end
    return table.concat(parts)
end

local function test_parse_round_trip_special_names()
    local dir = reset_dir "round-trip-names"
    local names = { "with space.txt", 'quote"name.txt', "café.txt", "line\nbreak.txt" }
    for _, name in ipairs(names) do
        vim.fn.writefile({ "x" }, dir .. "/" .. name)
    end
    local buf = new_manager(dir)
    local entries = view.parse_buffer(buf)
    check(entries ~= nil, "parse should succeed for special names")
    local found = {}
    for _, item in ipairs(entries or {}) do
        found[item.entry.fs_name] = item.entry
    end
    for _, name in ipairs(names) do
        check(found[name] ~= nil, "round-trip missing name: " .. string.format("%q", name))
        if found[name] then
            eq(found[name].kind, "file", "kind for " .. string.format("%q", name))
        end
    end
    local ops, err = plan.plan_ops(buf)
    eq(#(ops or {}), 0, "unchanged special names should not create ops: " .. tostring(err))
end

local function test_quoted_directory_round_trip()
    local dir = reset_dir "round-trip-dir"
    local name = "dir\nquoted"
    vim.fn.mkdir(dir .. "/" .. name, "p")
    vim.fn.writefile({ "x" }, dir .. "/" .. name .. "/child.txt")
    local buf = new_manager(dir)
    local entries = view.parse_buffer(buf)
    local found
    for _, item in ipairs(entries or {}) do
        if item.entry.kind == "directory" then
            found = item.entry.fs_name
        end
    end
    eq(found, name, "quoted directory name round-trip")
    local ops, err = plan.plan_ops(buf)
    eq(#(ops or {}), 0, "unchanged directory should not create ops: " .. tostring(err))
end

local function test_special_mode_display()
    local dir = reset_dir "mode-special-bits"
    local file = dir .. "/setuid.txt"
    vim.fn.writefile({ "x" }, file)
    local uv = vim.uv or vim.loop
    uv.fs_chmod(file, tonumber("4755", 8))
    local buf = new_manager(dir)
    local row = row_with(buf, "setuid.txt")
    check(row ~= nil, "setuid row should be rendered")
    if row then
        local text = virt_text_for_row(buf, row)
        check(text:find("s", 1, true) ~= nil, "setuid bit should render as s: " .. text)
    end
end

local function test_format_mode_special_bits()
    eq(
        render.format_mode(tonumber("4755", 8)),
        "rwsr-xr-x",
        "setuid must not imply setgid or sticky"
    )
    eq(render.format_mode(tonumber("2755", 8)), "rwxr-sr-x", "setgid must not imply sticky")
    eq(render.format_mode(tonumber("1755", 8)), "rwxr-xr-t", "sticky mode")
    eq(render.format_mode(tonumber("6755", 8)), "rwsr-sr-x", "setuid+setgid must not imply sticky")
end

local function test_plan_error_highlights_parse_error()
    local dir = reset_dir "plan-error-highlight-parse"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)
    local row = row_with(buf, "A.txt")
    check(row ~= nil, "parse error test needs a row")
    if not row then
        return
    end
    set_row(buf, row, "/0 A.txt")

    render.add_virtual_text(buf, dir)
    local st = state.get(buf)
    check(
        st.plan_error and st.plan_error:find("line " .. (row + 1), 1, true) ~= nil,
        "parse error should name the offending line: " .. tostring(st.plan_error)
    )
    eq(#(st.plan_error_rows or {}), 1, "parse error should report one row")
    eq(st.plan_error_rows[1], row, "parse error should use a zero-based buffer row")
    check(
        header_error_text(buf):find("(rows " .. (row + 1) .. ")", 1, true) ~= nil,
        "header should list the parse-error row"
    )
    check(row_set(plan_error_highlight_rows(buf))[row], "parse-error row should be highlighted")
end

local function test_child_root_rejects_escaping_names()
    local dir = reset_dir "root-escape"
    eq(root.child_root(dir, "sub"), dir .. "/sub/", "normal child root")
    eq(root.child_root(dir, "../elsewhere"), dir .. "/", "parent traversal must not escape root")
    eq(root.child_root(dir, "/etc"), dir .. "/", "absolute child must not escape root")
end

local function test_path_validation_guards_nil()
    eq(path_validation.is_valid_rel_path(nil), false, "nil relative path is invalid")
    local ok, err = path_validation.validate_rel_dir(nil)
    eq(ok, false, "nil relative dir is invalid")
    check(err ~= nil, "nil relative dir should explain the error")
end

local function test_git_status_without_vim_system()
    local dir = reset_dir "git-no-system"
    local original_system = vim.system
    local result = nil
    vim.system = nil
    git.fetch_status(dir, function(status, files, meta)
        result = { status = status, files = files, meta = meta }
    end)
    vim.system = original_system
    vim.wait(2000, function()
        return result ~= nil
    end, 10)
    check(result ~= nil, "git status callback should run without vim.system")
    if result then
        eq(result.meta and result.meta.available, false, "git should be unavailable")
        check(
            result.meta
                and result.meta.reason
                and result.meta.reason:find("vim.system", 1, true) ~= nil,
            "reason should name the missing API: " .. tostring(result.meta and result.meta.reason)
        )
    end
end

local function test_git_status_outside_repository()
    local dir = reset_dir "git-no-repo"
    local result = nil
    git.fetch_status(dir, function(status, files, meta)
        result = { status = status, files = files, meta = meta }
    end)
    vim.wait(3000, function()
        return result ~= nil
    end, 10)
    check(result ~= nil, "git status callback should run outside a repository")
    if result then
        eq(result.meta and result.meta.available, false, "non-repo should be unavailable")
        check(
            result.meta and result.meta.reason and result.meta.reason ~= "",
            "non-repo should explain why git status is unavailable"
        )
    end
end

local function test_open_unreadable_root_notifies()
    vim.cmd "silent! %bwipeout!"
    local buf = vim.api.nvim_get_current_buf()
    local original_err_notify = utils.err_notify
    local message = nil
    utils.err_notify = function(msg)
        message = msg
    end
    local opened = open.open("/definitely/missing/adev-files-root", { mode = "current", buf = buf })
    utils.err_notify = original_err_notify
    eq(opened, nil, "open should not return a buffer for an unreadable root")
    check(
        message and message:find("Cannot read", 1, true) ~= nil,
        "unreadable root should notify with the reason: " .. tostring(message)
    )
end

local function expected_winbar(dir, total)
    local normalized = root.normalize_root(dir)
    local escaped = normalized:gsub("%%", "%%%%")
    local suffix = total and (" [%d]"):format(total) or ""
    return "Adev Files [" .. escaped .. "] [?: help]" .. suffix
end

local function title_text(title)
    if type(title) == "string" then
        return title
    end
    local chunks = {}
    for _, chunk in ipairs(title or {}) do
        local text = type(chunk) == "table" and tostring(chunk[1] or "") or tostring(chunk)
        table.insert(chunks, text)
    end
    return table.concat(chunks)
end

local function test_open_escapes_percent_in_current_winbar()
    local dir = reset_dir "winbar-percent-open-%value"
    write_file(dir .. "/A.txt", "alpha")
    vim.cmd "silent! only"
    local buf = new_manager(dir)
    local win = vim.fn.bufwinid(buf)
    check(win ~= -1, "manager window should exist")
    if win == -1 then
        return
    end
    eq(vim.wo[win].winbar, expected_winbar(dir), "open should escape percent signs in the winbar")
end

local function test_set_title_from_state_escapes_percent_in_current_winbar()
    local dir = reset_dir "winbar-percent-state-%value"
    write_file(dir .. "/A.txt", "alpha")
    vim.cmd "silent! only"
    local buf = new_manager(dir)
    local win = vim.fn.bufwinid(buf)
    check(win ~= -1, "manager window should exist")
    if win == -1 then
        return
    end
    window.set_title_from_state(buf, root.normalize_root(dir), 2)
    eq(
        vim.wo[win].winbar,
        expected_winbar(dir, 2),
        "set_title_from_state should escape percent signs in the winbar"
    )
end

local function test_floating_title_keeps_percent_signs_raw()
    local dir = reset_dir "winbar-percent-float-%value"
    write_file(dir .. "/A.txt", "alpha")
    vim.cmd "silent! only"
    local buf = open.open(dir, { mode = "float" })
    check(buf ~= nil, "float open should return a buffer")
    if not buf then
        return
    end
    local win = vim.fn.bufwinid(buf)
    check(win ~= -1, "floating manager window should exist")
    if win == -1 then
        return
    end
    window.set_title_from_state(buf, root.normalize_root(dir), 1)
    local cfg = vim.api.nvim_win_get_config(win)
    local normalized = root.normalize_root(dir)
    eq(
        title_text(cfg.title),
        "Adev Files [" .. normalized .. "] [?: help] [1]",
        "floating titles must keep raw percent signs"
    )
end

local function test_chmod_accepts_four_digit_mode()
    local dir = reset_dir "chmod-special"
    local file = dir .. "/script.sh"
    write_file(file, "#!/bin/sh\n")
    check(uv.fs_chmod(file, 493), "chmod setup failed")
    local buf = new_manager(dir)
    cursor_row(buf, "script.sh")

    local original_input = vim.ui.input
    local prompt = nil
    vim.ui.input = function(opts, cb)
        prompt = opts.prompt
        cb "4755"
    end
    chmod.chmod_entry(buf)
    vim.ui.input = original_input

    local stat = uv.fs_stat(file)
    check(stat ~= nil, "chmod should leave the file in place")
    if stat then
        eq(stat.mode % 4096, tonumber("4755", 8), "setuid bit must survive chmod")
    end
    check(
        prompt
            and prompt:find("Permissions for", 1, true) ~= nil
            and prompt:find("rwxr-xr-x", 1, true) ~= nil,
        "chmod prompt should show the current mode"
    )
end

local function test_clipboard_single_hop_relocation()
    local dir = reset_dir "clipboard-chain"
    clipboard.set("copy", { { kind = "file", src = dir .. "/old/nested/file.txt" } })
    clipboard.apply_path_changes {
        { type = "rename", src = dir .. "/old", dst = dir .. "/middle", kind = "directory" },
        { type = "rename", src = dir .. "/middle", dst = dir .. "/new", kind = "directory" },
    }
    local clip = clipboard.get()
    check(clip and clip.items and clip.items[1], "clipboard should survive simultaneous renames")
    if clip and clip.items[1] then
        eq(
            clip.items[1].src,
            dir .. "/middle/nested/file.txt",
            "only the matching relocation should be applied"
        )
    end
    clipboard.clear()
end

local function test_header_row_cannot_be_marked()
    local dir = reset_dir "header-mark"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)
    local win = vim.fn.bufwinid(buf)
    check(win ~= -1, "manager window should exist")
    if win ~= -1 then
        vim.api.nvim_win_set_cursor(win, { 1, 0 })
    end
    selection.toggle_mark(buf)
    eq(next(state.get_selection_marks(buf)), nil, "the virtual header row must not be markable")
end

local function write_three_entries(dir)
    write_file(dir .. "/A.txt", "alpha")
    write_file(dir .. "/B.txt", "beta")
    write_file(dir .. "/C.txt", "gamma")
end

local function split_manager()
    local first_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_cursor(first_win, { 2, 0 })
    vim.cmd "vsplit"
    local second_win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_cursor(second_win, { 4, 0 })
    return first_win, second_win
end

local function test_selection_uses_current_manager_window()
    local dir = reset_dir "selection-current-window"
    write_three_entries(dir)
    vim.cmd "silent! only"
    local buf = new_manager(dir)
    split_manager()

    selection.toggle_mark(buf)

    local marks = state.get_selection_marks(buf)
    eq(marks[3], true, "selection should use the current manager window")
    eq(marks[1], nil, "selection should not use the fallback window")
end

local function test_navigation_uses_current_manager_window()
    local dir = reset_dir "navigation-current-window"
    write_three_entries(dir)
    vim.cmd "silent! only"
    local buf = new_manager(dir)
    set_row(buf, row_with(buf, "B.txt"), "B_renamed.txt")

    local first_win, second_win = split_manager()
    vim.api.nvim_win_set_cursor(first_win, { 4, 0 })
    vim.api.nvim_win_set_cursor(second_win, { 2, 0 })
    navigation.next_modification(buf)

    eq(vim.api.nvim_win_get_cursor(second_win)[1], 3, "navigation should move the current window")
    eq(
        vim.api.nvim_win_get_cursor(first_win)[1],
        4,
        "navigation should not move the fallback window"
    )
end

local function test_revert_uses_current_manager_window()
    local dir = reset_dir "revert-current-window"
    write_three_entries(dir)
    vim.cmd "silent! only"
    local buf = new_manager(dir)
    local b_row = row_with(buf, "B.txt")
    set_row(buf, b_row, "B_renamed.txt")

    local first_win, second_win = split_manager()
    vim.api.nvim_win_set_cursor(first_win, { 4, 0 })
    vim.api.nvim_win_set_cursor(second_win, { b_row + 1, 0 })
    revert.revert_current_line(buf)

    check(
        lines(buf)[b_row + 1]:find("B.txt", 1, true) ~= nil,
        "revert should target the current window's row"
    )
    check(lines(buf)[4]:find("C.txt", 1, true) ~= nil, "revert should not target the fallback row")
end

local function test_paste_uses_current_manager_window()
    local dir = reset_dir "paste-current-window"
    write_three_entries(dir)
    vim.cmd "silent! only"
    local buf = new_manager(dir)

    cursor_row(buf, "A.txt")
    clipboard_events.set_clipboard(buf, "copy")
    split_manager()
    clipboard_events.paste(buf, "")

    local last = lines(buf)[#lines(buf)]
    check(last:find("A_1.txt", 1, true) ~= nil, "paste should use the current window's cursor")
end

local function test_reattach_replaces_on_lines_callback()
    local dir = reset_dir "attach-idempotent"
    write_file(dir .. "/A.txt", "alpha")
    local real_attach = vim.api.nvim_buf_attach
    local real_detach = vim.api.nvim_buf_detach
    local active = 0
    vim.api.nvim_buf_attach = function(buf, send_buffer, opts)
        active = active + 1
        local ok = real_attach(buf, send_buffer, opts)
        if not ok then
            active = active - 1
        end
        return ok
    end
    vim.api.nvim_buf_detach = function(buf)
        local ok = real_detach(buf)
        if ok then
            active = active - 1
        end
        return ok
    end

    local ok, err = pcall(function()
        local buf = new_manager(dir)
        attach.attach(buf, dir)
        eq(active, 1, "reattaching a manager must replace the old buffer callback")
    end)
    vim.api.nvim_buf_attach = real_attach
    vim.api.nvim_buf_detach = real_detach
    if not ok then
        fail("reattach regression crashed: " .. tostring(err))
    end
end

local function test_confirmation_restores_modifiable_when_state_replaced()
    local dir = reset_dir "confirm-state-replaced"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)
    set_row(buf, row_with(buf, "A.txt"), "Changed.txt")
    local original_open = confirmation.open
    confirmation.open = function(_, _, cb)
        state.init(buf, dir)
        cb(true)
    end
    local called = nil
    confirm_events.confirm_discard_if_modified(buf, "/tmp/destination", function(ok)
        called = ok
    end)
    confirmation.open = original_open
    eq(vim.bo[buf].modifiable, true, "stale confirmation must restore modifiable")
    eq(called, false, "stale confirmation must not discard against a replaced state")
end

local function test_confirmation_escapes_destination_control_chars()
    local dir = reset_dir "confirm-control-chars"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)
    set_row(buf, row_with(buf, "A.txt"), "Changed.txt")

    local captured
    local original_open = confirmation.open
    confirmation.open = function(lines, _, cb)
        captured = lines
        cb(false)
    end
    local called = nil
    confirm_events.confirm_discard_if_modified(buf, dir .. "/line\nbreak.txt", function(ok)
        called = ok
    end)
    confirmation.open = original_open

    eq(#captured, 2, "destination should remain one buffer line")
    check(captured[2]:find("\n", 1, true) == nil, "destination newlines must be escaped")
    check(captured[2]:find("line", 1, true) ~= nil, "destination text should be preserved")
    eq(state.get(buf).confirming, false, "confirmation must clear confirming")
    eq(vim.bo[buf].modifiable, true, "confirmation must restore modifiable")
    eq(called, false, "cancel should report false")
end

local function test_confirmation_open_failure_restores_state()
    local dir = reset_dir "confirm-open-failure"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)
    set_row(buf, row_with(buf, "A.txt"), "Changed.txt")

    local original_open = confirmation.open
    local original_err_notify = utils.err_notify
    local message
    confirmation.open = function()
        error "simulated prompt failure"
    end
    utils.err_notify = function(msg)
        message = msg
    end
    local called = nil
    local ok, err = pcall(confirm_events.confirm_discard_if_modified, buf, dir, function(confirmed)
        called = confirmed
    end)
    confirmation.open = original_open
    utils.err_notify = original_err_notify

    check(ok, "prompt creation failure must not propagate: " .. tostring(err))
    eq(state.get(buf).confirming, false, "failed prompt must clear confirming")
    eq(vim.bo[buf].modifiable, true, "failed prompt must restore modifiable")
    eq(called, false, "failed prompt must cancel callback")
    check(
        message and message:find("simulated prompt failure", 1, true) ~= nil,
        "prompt failure should be reported: " .. tostring(message)
    )
end

local function test_failed_refresh_keeps_buffer_read_only()
    local dir = reset_dir "refresh-failure"
    write_file(dir .. "/A.txt", "alpha")
    local buf = new_manager(dir)
    local st = state.get(buf)
    st.needs_refresh = true
    st.refresh_modifiable = false
    local original_build = listing.build_lines
    listing.build_lines = function()
        return nil, "simulated listing failure"
    end
    local ok = sync_view.refresh(buf, { force = true })
    listing.build_lines = original_build
    eq(ok, false, "refresh should report the listing failure")
    eq(vim.bo[buf].modifiable, false, "failed refresh must keep the buffer read-only")
    eq(st.needs_refresh, true, "failed refresh must keep needs_refresh")
    eq(st.refresh_modifiable, nil, "failed refresh must not keep stale refresh intent")
end

local function test_scandir_next_error_is_surfaced()
    local dir = reset_dir "scandir-error"
    write_file(dir .. "/A.txt", "alpha")
    local real_next = vim.uv.fs_scandir_next
    vim.uv.fs_scandir_next = function()
        return nil, nil, "simulated scandir error"
    end
    local lines, err = listing.build_lines(dir)
    vim.uv.fs_scandir_next = real_next
    eq(lines, nil, "scandir_next error must fail the listing")
    check(
        err and err:find("simulated scandir error", 1, true) ~= nil,
        "scandir_next error must be reported: " .. tostring(err)
    )
end

local function test_delete_preview_counts_small_tree_exactly()
    local dir = reset_dir "delete-preview-small"
    local tree = dir .. "/tree"
    vim.fn.mkdir(tree .. "/sub/deep", "p")
    write_file(tree .. "/a.txt", "a")
    write_file(tree .. "/sub/b.txt", "b")
    write_file(tree .. "/sub/deep/c.txt", "c")

    local formatted = format.format_ops({ root = dir }, {
        { type = "delete", path = tree, kind = "directory" },
    })
    eq(
        formatted[1] or "",
        "recursive delete (5 descendants): tree/",
        "small delete preview should count every descendant"
    )
end

local function test_delete_preview_is_bounded()
    local dir = reset_dir "delete-preview-cap"
    local tree = dir .. "/tree"
    vim.fn.mkdir(tree, "p")
    local real_scandir = uv.fs_scandir
    local real_next = uv.fs_scandir_next
    local next_calls = 0
    uv.fs_scandir = function()
        return { index = 0 }
    end
    uv.fs_scandir_next = function(handle)
        next_calls = next_calls + 1
        handle.index = handle.index + 1
        if handle.index <= 5000 then
            return "f" .. handle.index, "file"
        end
        return nil
    end

    local formatted = format.format_ops({ root = dir }, {
        { type = "delete", path = tree, kind = "directory" },
    })
    uv.fs_scandir = real_scandir
    uv.fs_scandir_next = real_next

    local line = formatted[1] or ""
    check(
        line:find("recursive delete (at least 1000 descendants): tree/", 1, true) ~= nil,
        "capped delete preview should report a lower bound: " .. line
    )
    check(
        next_calls <= 1001,
        "delete preview should stop scanning at the cap: " .. tostring(next_calls)
    )
end

local tests = {
    test_copy_then_swap_rename,
    test_paste_consumes_clipboard,
    test_failed_paste_keeps_clipboard,
    test_copy_with_pending_rename,
    test_move_source_rename_rejected,
    test_plan_error_highlights_duplicate_path,
    test_plan_error_highlights_parse_error,
    test_parse_round_trip_special_names,
    test_quoted_directory_round_trip,
    test_special_mode_display,
    test_format_mode_special_bits,
    test_child_root_rejects_escaping_names,
    test_path_validation_guards_nil,
    test_open_unreadable_root_notifies,
    test_open_escapes_percent_in_current_winbar,
    test_set_title_from_state_escapes_percent_in_current_winbar,
    test_floating_title_keeps_percent_signs_raw,
    test_git_status_without_vim_system,
    test_git_status_outside_repository,
    test_chmod_accepts_four_digit_mode,
    test_clipboard_single_hop_relocation,
    test_header_row_cannot_be_marked,
    test_selection_uses_current_manager_window,
    test_navigation_uses_current_manager_window,
    test_revert_uses_current_manager_window,
    test_paste_uses_current_manager_window,
    test_reattach_replaces_on_lines_callback,
    test_confirmation_restores_modifiable_when_state_replaced,
    test_confirmation_escapes_destination_control_chars,
    test_confirmation_open_failure_restores_state,
    test_failed_refresh_keeps_buffer_read_only,
    test_scandir_next_error_is_surfaced,
    test_delete_preview_counts_small_tree_exactly,
    test_delete_preview_is_bounded,
    test_duplicate_id_recovery,
    test_delete_pasted_row_cancels_pending,
    test_delete_classifies_before_cancelling_pending,
    test_delete_failed_plan_does_not_stage_original,
    test_delete_marker_cancels_pending,
    test_kind_change_rejected,
    test_directory_into_itself,
    test_same_path_copy_with_delete_rejected,
    test_clipboard_path_changes,
    test_directory_rename_remaps_clipboard_child,
    test_move_destination_rename,
    test_whole_line_edit_preserves_identity,
    test_delete_move_source_rejected,
    test_delete_pending_copy_source,
    test_move_plus_same_path_copy,
    test_duplicate_destination_rejected,
    test_nested_destination_rejected,
    test_relative_symlink_copy_is_rebased,
    test_cross_device_move_remaps_internal_symlink,
    test_cross_device_move_preserves_top_level_symlink,
    test_cross_device_move_resolves_symlinked_source_parent,
    test_symlink_to_directory_copies_contents,
    test_directory_rename_then_create_inside,
    test_malformed_staged_op_rejected_before_abs,
    test_staged_op_without_dst_id_runs_once,
}

for _, test in ipairs(tests) do
    local ok, err = pcall(test)
    if not ok then
        fail("test crashed: " .. tostring(err))
    end
end

if failures > 0 then
    io.write(string.format("\n%d failure(s)\n", failures))
    vim.cmd "cq"
else
    io.write "\nall adev-files edge-case tests passed\n"
    vim.cmd "qa!"
end
