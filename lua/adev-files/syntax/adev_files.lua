if vim.b.current_syntax then
    return
end

vim.cmd [[syntax match adevFilesHelp "^│.*$" contains=adevFilesHelpKey]]

vim.cmd [[syntax match adevFilesHelpKey "\c<CR>" contained containedin=adevFilesHelp]]
vim.cmd [[syntax match adevFilesHelpKey "\c<bs>" contained containedin=adevFilesHelp]]
vim.cmd [[syntax match adevFilesHelpKey "[=?]" contained containedin=adevFilesHelp]]
vim.cmd [[syntax match adevFilesHelpKey "ny" contained containedin=adevFilesHelp]]
vim.cmd [[syntax match adevFilesHelpKey "nx" contained containedin=adevFilesHelp]]
vim.cmd [[syntax match adevFilesHelpKey "np" contained containedin=adevFilesHelp]]
vim.cmd [[syntax match adevFilesHelpKey "nd" contained containedin=adevFilesHelp]]
vim.cmd [[syntax match adevFilesHelpKey "nc" contained containedin=adevFilesHelp]]

vim.cmd [[syntax match adevFilesSeparator "^=\+$"]]

vim.cmd [[syntax match adevFilesDirValue "^.\+/$"]]

vim.cmd [[syntax match adevFilesTitle "^root:.*$"]]

vim.cmd [[syntax match adevFilesGroupSep "^$"]]

vim.cmd [[syntax match adevFilesFileValue "^[^r│=].*[^/]$"]]
vim.cmd [[syntax match adevFilesFileValue "^r[^o].*[^/]$"]]
vim.cmd [[syntax match adevFilesFileValue "^ro[^o].*[^/]$"]]
vim.cmd [[syntax match adevFilesFileValue "^roo[^t].*[^/]$"]]
vim.cmd [[syntax match adevFilesFileValue "^root[^:].*[^/]$"]]

vim.api.nvim_set_hl(0, "adevFilesHelp", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "adevFilesHelpKey", { link = "Identifier", default = true })
vim.api.nvim_set_hl(0, "adevFilesSeparator", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "adevFilesGroupSep", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "adevFilesTitle", { link = "Type", default = true })
vim.api.nvim_set_hl(0, "adevFilesDirValue", { link = "Function", default = true })
vim.api.nvim_set_hl(0, "adevFilesFileValue", { link = "Normal", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingDelete", { link = "adevFilesGitDeleted", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingCopy", { link = "adevFilesGitCopied", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingMove", { link = "adevFilesGitModified", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingNew", { link = "adevFilesGitAdded", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingRenamed", { link = "adevFilesGitRenamed", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingMark", { link = "Special", default = true })
vim.api.nvim_set_hl(0, "adevFilesPermRead", { link = "Constant", default = true })
vim.api.nvim_set_hl(0, "adevFilesPermWrite", { link = "PreProc", default = true })
vim.api.nvim_set_hl(0, "adevFilesPermExec", { link = "Function", default = true })
vim.api.nvim_set_hl(0, "adevFilesPermDash", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitModified", { link = "DiffChange", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitAdded", { link = "DiffAdd", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitDeleted", { link = "DiffDelete", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitRenamed", { link = "DiffText", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitCopied", { link = "Special", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitUntracked", { link = "Comment", default = true })

vim.b.current_syntax = "adev_files"
