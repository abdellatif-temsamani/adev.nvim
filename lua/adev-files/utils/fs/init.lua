local M = {}

local copy_file = require "adev-files.utils.fs.copy_file"
local copy_dir = require "adev-files.utils.fs.copy_dir"
local mkdir = require "adev-files.utils.fs.mkdir"
local stat = require "adev-files.utils.fs.stat"

M.stat = stat.stat
M.lstat = stat.lstat
M.exists = stat.exists

M.mkdir_p = mkdir.mkdir_p

M.copy_file = copy_file.copy_file
M.copy_dir_recursive = copy_dir.copy_dir_recursive

return M
