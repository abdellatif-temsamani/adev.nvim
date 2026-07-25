if vim.b.current_syntax then
    return
end

vim.cmd [[syntax match adevFilesHelpTitle "^  adev-files$"]]
vim.cmd [[syntax match adevFilesHelpSection "^  \w\+\ze$"]]
vim.cmd [[syntax match adevFilesHelpKey "\%(^    \)\zs.\{-}\ze\s\{2,\}"]]
vim.cmd [[syntax match adevFilesHelpDesc "\%(^    .\{-}\s\{2,\}\)\zs.\+$"]]

vim.api.nvim_set_hl(0, "adevFilesHelpTitle", { link = "Title", default = true })
vim.api.nvim_set_hl(0, "adevFilesHelpSection", { link = "Statement", default = true })
vim.api.nvim_set_hl(0, "adevFilesHelpKey", { link = "Function", default = true })
vim.api.nvim_set_hl(0, "adevFilesHelpDesc", { link = "Comment", default = true })

vim.b.current_syntax = "adev_files_help"
