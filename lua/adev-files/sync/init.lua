local M = {}

local view = require "adev-files.sync.view"
local plan = require "adev-files.sync.plan"
local apply = require "adev-files.sync.apply"
local attach = require "adev-files.sync.attach"

M.refresh = view.refresh
M.set_root = view.set_root

M.plan_ops = plan.plan_ops
M.apply_ops_with_confirm = apply.apply_ops_with_confirm
M.attach = attach.attach

return M
