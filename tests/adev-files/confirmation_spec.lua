vim.opt.runtimepath:append(vim.fn.getcwd())

local confirmation = require "adev-files.utils.confirmation"

---@param key string
---@param expected boolean
local function check_close(key, expected)
    local result
    confirmation.open({ "Apply changes?" }, { title = "adev-files test" }, function(confirmed)
        result = confirmed
    end)

    local buf = vim.api.nvim_get_current_buf()
    local windows = vim.fn.win_findbuf(buf)
    assert(#windows == 1)
    assert(vim.api.nvim_win_get_config(windows[1]).relative ~= "")

    local keys = vim.api.nvim_replace_termcodes(key, true, false, true)
    vim.api.nvim_feedkeys(keys, "x", false)
    vim.wait(100, function()
        return result ~= nil
    end)

    assert(result == expected)
    assert(not vim.api.nvim_buf_is_valid(buf))
    assert(#vim.fn.win_findbuf(buf) == 0)
end

check_close("y", true)
check_close("q", false)

print "confirmation close tests passed"
