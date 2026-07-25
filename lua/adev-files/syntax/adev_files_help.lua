if vim.b.current_syntax then
  return
end

vim.cmd([[syntax match adevFilesHelpTitle "^  adev-files$"]])
vim.cmd([[syntax match adevFilesHelpSection "^  \w\+\ze$"]])
vim.cmd([[syntax match adevFilesHelpKey "\S\+\ze\s\{2,\}"]])
vim.cmd([[syntax match adevFilesHelpDesc "\(\s\{4,\}\)\@<=.\+"]])

vim.api.nvim_set_hl(0, "adevFilesHelpTitle", { link = "Title" })
vim.api.nvim_set_hl(0, "adevFilesHelpSection", { link = "Statement" })
vim.api.nvim_set_hl(0, "adevFilesHelpKey", { link = "Identifier" })
vim.api.nvim_set_hl(0, "adevFilesHelpDesc", { link = "Comment" })

vim.b.current_syntax = "adev_files_help"
