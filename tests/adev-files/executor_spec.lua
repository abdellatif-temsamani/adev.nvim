vim.opt.runtimepath:append(vim.fn.getcwd())

local executor = require "adev-files.core.executor"
local fs = require "adev-files.utils.fs"
local uv = vim.uv or vim.loop

local function perm(str)
    str = str:gsub("%s+", "")
    local num = 0
    local bits = { 256, 128, 64, 32, 16, 8, 4, 2, 1 }
    for i = 1, 9 do
        local ch = str:sub(i, i)
        if ch == "r" or ch == "w" or ch == "x" then
            num = num + bits[i]
        end
    end
    return num
end

local function chmod(path, str)
    return uv.fs_chmod(path, perm(str))
end

local tests = {}

local function exists(path)
    return uv.fs_lstat(path) ~= nil
end

local function write_file(path, contents)
    local fd = assert(uv.fs_open(path, "w", 420))
    assert(uv.fs_write(fd, contents, 0))
    assert(uv.fs_close(fd))
end

local function read_file(path)
    local fd = assert(uv.fs_open(path, "r", 438))
    local stat = assert(uv.fs_fstat(fd))
    local contents = assert(uv.fs_read(fd, stat.size, 0))
    assert(uv.fs_close(fd))
    return contents
end

local function with_temp_dir(run)
    local root = vim.fn.tempname()
    assert(vim.fn.mkdir(root, "p") == 1)
    local ok, err = xpcall(function()
        run(root)
    end, debug.traceback)
    chmod(root, "rwxr-xr-x")
    vim.fn.delete(root, "rf")
    if not ok then
        error(err)
    end
end

function tests.rm_rf_reports_delete_failure()
    with_temp_dir(function(root)
        local target = root .. "/locked.txt"
        write_file(target, "keep")
        assert(chmod(root, "r-xr-xr-x"))

        local ok, err = fs.rm_rf(target)

        assert(ok == false)
        assert(type(err) == "string" and err:match "failed to delete")
        assert(exists(target))
        assert(chmod(root, "rwxr-xr-x"))
    end)
end

function tests.preflight_collision_does_not_apply_earlier_operations()
    with_temp_dir(function(root)
        local first = root .. "/first"
        local second = root .. "/second"
        write_file(second, "existing")

        local ok, err = executor.apply_ops {
            { type = "create", kind = "file", path = first },
            { type = "create", kind = "file", path = second },
        }

        assert(ok == false)
        assert(type(err) == "string" and err:match "target exists")
        assert(not exists(first))
        assert(read_file(second) == "existing")
    end)
end

function tests.runtime_failure_rolls_back_created_paths()
    with_temp_dir(function(root)
        local first = root .. "/first"
        local locked = root .. "/locked"
        assert(vim.fn.mkdir(locked, "p") == 1)
        assert(chmod(locked, "r-xr-xr-x"))

        local ok = executor.apply_ops {
            { type = "create", kind = "file", path = first },
            { type = "create", kind = "file", path = locked .. "/second" },
        }

        assert(ok == false)
        assert(not exists(first))
        assert(not exists(locked .. "/second"))
        assert(chmod(locked, "rwxr-xr-x"))
    end)
end

function tests.runtime_failure_restores_staged_rename()
    with_temp_dir(function(root)
        local source = root .. "/source"
        local destination = root .. "/destination"
        local locked = root .. "/locked"
        write_file(source, "original")
        assert(vim.fn.mkdir(locked, "p") == 1)
        assert(chmod(locked, "r-xr-xr-x"))

        local ok = executor.apply_ops {
            { type = "rename", kind = "file", src = source, dst = destination },
            { type = "create", kind = "file", path = locked .. "/failure" },
        }

        assert(ok == false)
        assert(read_file(source) == "original")
        assert(not exists(destination))
        assert(not exists(locked .. "/failure"))
        assert(chmod(locked, "rwxr-xr-x"))
    end)
end

function tests.rename_swap_commits_as_one_batch()
    with_temp_dir(function(root)
        local a = root .. "/a"
        local b = root .. "/b"
        write_file(a, "A")
        write_file(b, "B")

        local ok, err = executor.apply_ops {
            { type = "rename", kind = "file", src = a, dst = b },
            { type = "rename", kind = "file", src = b, dst = a },
        }

        assert(ok == true, err)
        assert(read_file(a) == "B")
        assert(read_file(b) == "A")
    end)
end

function tests.mixed_batch_commits_all_operation_types()
    with_temp_dir(function(root)
        local deleted = root .. "/deleted"
        local renamed = root .. "/renamed-source"
        local copied = root .. "/copied-source"
        local moved = root .. "/moved-source"
        assert(vim.fn.mkdir(deleted, "p") == 1)
        write_file(deleted .. "/child", "delete")
        write_file(renamed, "rename")
        write_file(copied, "copy")
        write_file(moved, "move")

        local ok, err = executor.apply_ops {
            { type = "delete", kind = "directory", path = deleted },
            { type = "rename", kind = "file", src = renamed, dst = root .. "/renamed" },
            { type = "copy", kind = "file", src = copied, dst = root .. "/copied" },
            { type = "move", kind = "file", src = moved, dst = root .. "/moved" },
            { type = "create", kind = "file", path = root .. "/created" },
            { type = "create", kind = "directory", path = root .. "/created-dir" },
        }

        assert(ok == true, err)
        assert(not exists(deleted))
        assert(not exists(renamed))
        assert(read_file(root .. "/renamed") == "rename")
        assert(read_file(copied) == "copy")
        assert(read_file(root .. "/copied") == "copy")
        assert(not exists(moved))
        assert(read_file(root .. "/moved") == "move")
        assert(read_file(root .. "/created") == "")
        assert(vim.fn.isdirectory(root .. "/created-dir") == 1)

        for name in vim.fs.dir(root) do
            assert(not name:match "^%.adev%-files%-txn%")
        end
    end)
end

local names = vim.tbl_keys(tests)
table.sort(names)
for _, name in ipairs(names) do
    tests[name]()
    print("ok - " .. name)
end

print(string.format("%d tests passed", #names))
