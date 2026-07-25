if vim.b.current_syntax then
    return
end

vim.cmd [[syntax match adevChangesSection "^Changes staged:\|^Changes pending:"]]
vim.cmd [[syntax match adevChangesCreate "\v^\s+created:"]]
vim.cmd [[syntax match adevChangesDelete "\v^\s+deleted:"]]
vim.cmd [[syntax match adevChangesRename "\v^\s+renamed:" contains=adevChangesArrow]]
vim.cmd [[syntax match adevChangesMove   "\v^\s+moved:"   contains=adevChangesArrow]]
vim.cmd [[syntax match adevChangesCopy   "\v^\s+copied:"   contains=adevChangesArrow]]
vim.cmd [[syntax match adevChangesArrow " -> " contained]]
vim.cmd [[syntax match adevChangesNone   "(no changes)"]]

vim.api.nvim_set_hl(0, "adevChangesSection", { link = "Title", default = true })
vim.api.nvim_set_hl(0, "adevChangesCreate", { link = "DiffAdd", default = true })
vim.api.nvim_set_hl(0, "adevChangesDelete", { link = "DiffDelete", default = true })
vim.api.nvim_set_hl(0, "adevChangesRename", { link = "DiffText", default = true })
vim.api.nvim_set_hl(0, "adevChangesMove", { link = "DiffChange", default = true })
vim.api.nvim_set_hl(0, "adevChangesCopy", { link = "Special", default = true })
vim.api.nvim_set_hl(0, "adevChangesArrow", { link = "Operator", default = true })
vim.api.nvim_set_hl(0, "adevChangesNone", { link = "Comment", default = true })

vim.b.current_syntax = "adev_changes"
