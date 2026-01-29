local M = {}

local listing = require "adev-files.file_manager.listing"
local open = require "adev-files.file_manager.open"
local render = require "adev-files.file_manager.render"
local roots = require "adev-files.file_manager.roots"

M.normalize_root = roots.normalize_root
M.child_root = roots.child_root
M.parent_root = roots.parent_root

M.build_lines = listing.build_lines
M.render = render.render

M.open = open.open

return M
