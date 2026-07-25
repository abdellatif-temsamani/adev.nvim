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

vim.api.nvim_set_hl(0, "adevFilesHelp", { link = "Comment" })
vim.api.nvim_set_hl(0, "adevFilesHelpKey", { link = "Identifier" })
vim.api.nvim_set_hl(0, "adevFilesSeparator", { link = "Comment" })
vim.api.nvim_set_hl(0, "adevFilesGroupSep", { link = "Comment" })
vim.api.nvim_set_hl(0, "adevFilesTitle", { link = "Type", bold = true, default = true })
vim.api.nvim_set_hl(0, "adevFilesDirValue", { link = "Function" })
vim.api.nvim_set_hl(0, "adevFilesFileValue", { link = "Normal" })
vim.api.nvim_set_hl(0, "adevFilesPendingDelete", { link = "adevFilesGitDeleted", default = true })
vim.api.nvim_set_hl(
    0,
    "adevFilesPendingCopy",
    { link = "adevFilesGitCopied", bold = true, default = true }
)
vim.api.nvim_set_hl(
    0,
    "adevFilesPendingMove",
    { link = "adevFilesGitModified", bold = true, default = true }
)
vim.api.nvim_set_hl(
    0,
    "adevFilesPendingNew",
    { link = "adevFilesGitAdded", bold = true, default = true }
)
vim.api.nvim_set_hl(
    0,
    "adevFilesPendingRenamed",
    { link = "adevFilesGitRenamed", bold = true, default = true }
)
vim.api.nvim_set_hl(0, "adevFilesPendingMark", { link = "Special", bold = true, default = true })
vim.api.nvim_set_hl(0, "adevFilesGitModified", { fg = "#E5C07B", bold = true })
vim.api.nvim_set_hl(0, "adevFilesGitAdded", { fg = "#98C379", bold = true })
vim.api.nvim_set_hl(0, "adevFilesGitDeleted", { fg = "#E06C75", bold = true })
vim.api.nvim_set_hl(0, "adevFilesGitRenamed", { fg = "#56B6C2", bold = true })
vim.api.nvim_set_hl(0, "adevFilesGitCopied", { fg = "#C678DD", bold = true })
vim.api.nvim_set_hl(0, "adevFilesGitUntracked", { fg = "#5C6370" })

vim.b.current_syntax = "adev_files"
