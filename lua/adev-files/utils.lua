local Utils = {
    name = "adev-files",
}

--- @param msg string
--- @param level integer|nil One of the values from |vim.log.levels|.
function Utils.notify(msg, level)
    vim.notify(msg, level, { title = Utils.name })
end

--- @param prompt string
--- @param default string
--- @param completion string
function Utils.input(prompt, default, completion, on_confirm)
    vim.ui.input({
        prompt = "[adev.files]: " .. prompt,
        default = default,
        completion = completion,
    }, on_confirm)
end

--- @param cwd string
--- @param buf? integer | nil
--- @return string
function Utils.get_basepath(cwd, buf)
    -- Get directory of current buffer relative to cwd
    local buf_path = vim.api.nvim_buf_get_name(0)
    local dir = vim.fn.fnamemodify(buf_path, ":h")
    if dir:sub(1, #cwd) == cwd then
        dir = dir:sub(#cwd + 2) -- +2 to remove trailing slash
    end

    if dir == "." then
        return ""
    end

    return dir
end

return Utils
