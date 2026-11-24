if vim.b.current_syntax then
    return
end

-- Buffer lines contain concealed entry IDs followed by editable filenames.
-- Header, icons, git markers, and pending labels are rendered via extmarks.
vim.cmd [[syntax match adevFilesEntryId "^/\d\+ " conceal]]
vim.api.nvim_set_hl(0, "adevFilesEntryId", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingDelete", { link = "adevFilesGitDeleted", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingCopy", { link = "adevFilesGitCopied", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingMove", { link = "adevFilesGitModified", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingNew", { link = "adevFilesGitAdded", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingRenamed", { link = "adevFilesGitRenamed", default = true })
vim.api.nvim_set_hl(0, "adevFilesPendingMark", { link = "Special", default = true })
vim.api.nvim_set_hl(0, "adevFilesSymlink", { link = "Special", default = true })
vim.api.nvim_set_hl(0, "adevFilesPermRead", { link = "Constant", default = true })
vim.api.nvim_set_hl(0, "adevFilesPermWrite", { link = "PreProc", default = true })
vim.api.nvim_set_hl(0, "adevFilesPermExec", { link = "Function", default = true })
vim.api.nvim_set_hl(0, "adevFilesPermDash", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitModified", { link = "DiffChange", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitAdded", { link = "DiffAdd", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitDeleted", { link = "DiffDelete", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitRenamed", { link = "DiffText", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitCopied", { link = "Special", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitUntracked", { link = "DiagnosticHint", default = true })
vim.api.nvim_set_hl(0, "adevFilesGitConflict", { link = "DiagnosticError", default = true })
vim.api.nvim_set_hl(0, "adevFilesPlanError", { link = "DiagnosticError", default = true })
vim.api.nvim_set_hl(0, "adevFilesGenericFile", { link = "Normal", default = true })

vim.b.current_syntax = "adev_files"
