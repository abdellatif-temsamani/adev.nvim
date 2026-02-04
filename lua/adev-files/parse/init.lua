local M = {}

local line = require "adev-files.parse.line"

M.parse_line = line.parse_line
M.strip_delete_marker = line.strip_delete_marker
M.toggle_delete_marker = line.toggle_delete_marker
M.mark_delete = line.mark_delete

return M
