if vim.b.current_syntax then
    return
end

vim.cmd [[syntax match adevChangesSection "^Staged ops:\|^Planned ops:"]]
vim.cmd [[syntax match adevChangesMove "\v^\s+move\s"]]
vim.cmd [[syntax match adevChangesCopy "\v^\s+copy\s"]]
vim.cmd [[syntax match adevChangesRename "\v^\s+rename\s"]]
vim.cmd [[syntax match adevChangesDelete "\v^\s+delete\s"]]
vim.cmd [[syntax match adevChangesCreate "\v^\s+create\s"]]
vim.cmd [[syntax match adevChangesArrow " -> "]]
vim.cmd [[syntax match adevChangesNone "(no pending changes)"]]

vim.api.nvim_set_hl(0, "adevChangesSection", { link = "Title" })
vim.api.nvim_set_hl(0, "adevChangesMove", { link = "adevFilesGitModified" })
vim.api.nvim_set_hl(0, "adevChangesCopy", { link = "adevFilesGitCopied" })
vim.api.nvim_set_hl(0, "adevChangesRename", { link = "adevFilesGitRenamed" })
vim.api.nvim_set_hl(0, "adevChangesDelete", { link = "adevFilesGitDeleted" })
vim.api.nvim_set_hl(0, "adevChangesCreate", { link = "adevFilesGitAdded" })
vim.api.nvim_set_hl(0, "adevChangesArrow", { link = "Special" })
vim.api.nvim_set_hl(0, "adevChangesNone", { link = "Comment" })

vim.b.current_syntax = "adev_changes"
