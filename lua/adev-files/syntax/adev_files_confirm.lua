if vim.b.current_syntax then
    vim.cmd "unlet b:current_syntax"
end

vim.cmd "silent! runtime lua/adev-files/syntax/adev_files.lua"

vim.cmd "silent! syntax clear adevFilesOp"
vim.cmd "silent! syntax clear adevFilesOpValue"

vim.cmd [[syn match adevFilesCreate "^create:" contained]]
vim.cmd [[syn match adevFilesDelete "^delete:" contained]]
vim.cmd [[syn match adevFilesRename "^rename:" contained]]
vim.cmd [[syn match adevFilesCopy   "^copy:"   contained]]
vim.cmd [[syn match adevFilesMove   "^move:"   contained]]
vim.cmd [[syn match adevFilesArrow " -> " contained]]
vim.cmd [[syn match adevFilesPath ":\s*\zs\S.*$" contained]]
vim.cmd [[syn match adevFilesSrcPath ":\s*\zs.\{-}\ze\s*->" contained]]
vim.cmd [[syn match adevFilesDstPath "->\s*\zs.*$" contained]]
vim.cmd [[syn match adevFilesCreateLine "^create:.*$" contains=adevFilesCreate,adevFilesPath]]
vim.cmd [[syn match adevFilesDeleteLine "^delete:.*$" contains=adevFilesDelete,adevFilesPath]]
vim.cmd [[syn match adevFilesRenameLine "^rename:.*$" contains=adevFilesRename,adevFilesArrow,adevFilesSrcPath,adevFilesDstPath]]
vim.cmd [[syn match adevFilesCopyLine   "^copy:.*$"   contains=adevFilesCopy,adevFilesArrow,adevFilesSrcPath,adevFilesDstPath]]
vim.cmd [[syn match adevFilesMoveLine   "^move:.*$"   contains=adevFilesMove,adevFilesArrow,adevFilesSrcPath,adevFilesDstPath]]
vim.cmd [[syn match adevFilesFooter "^[yn</].*$"]]

vim.api.nvim_set_hl(0, "adevFilesCreate", { link = "DiffAdd", default = true })
vim.api.nvim_set_hl(0, "adevFilesDelete", { link = "DiffDelete", default = true })
vim.api.nvim_set_hl(0, "adevFilesRename", { link = "DiffText", default = true })
vim.api.nvim_set_hl(0, "adevFilesCopy", { link = "Special", default = true })
vim.api.nvim_set_hl(0, "adevFilesMove", { link = "DiffChange", default = true })
vim.api.nvim_set_hl(0, "adevFilesArrow", { link = "Operator", default = true })
vim.api.nvim_set_hl(0, "adevFilesPath", { link = "String", default = true })
vim.api.nvim_set_hl(0, "adevFilesSrcPath", { link = "Comment", default = true })
vim.api.nvim_set_hl(0, "adevFilesDstPath", { link = "String", default = true })
vim.api.nvim_set_hl(0, "adevFilesFooter", { link = "Comment", default = true })

vim.b.current_syntax = "adev_files_confirm"
