local cmd = vim.cmd

local function get_output_path()
    local path = vim.api.nvim_buf_get_name(0)
    return string.gsub(path, ".md", ".pdf")
end

local function pandoc_cmd(opts, use_template)
    local template = ""
    if use_template == true then
        template = "--template /home/flagmate/Templates/artical.tex "
    else
        template = ""
    end

    cmd(":!pandoc % " .. template .. opts .. " -o " .. get_output_path())
end

local wordcount = "--lua-filter " .. " ~/.local/share/pandoc/wordcount.lua "

local create_command = vim.api.nvim_create_user_command

create_command('WordCount', function() pandoc_cmd(wordcount, false) end,
    { nargs = 0 })
