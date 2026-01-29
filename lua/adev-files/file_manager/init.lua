local M = {}

local roots = require "adev-files.file_manager.roots"
local listing = require "adev-files.file_manager.listing"
local render = require "adev-files.file_manager.render"
local open = require "adev-files.file_manager.open"

M.normalize_root = roots.normalize_root
M.child_root = roots.child_root
M.parent_root = roots.parent_root

M.build_lines = listing.build_lines
M.render = render.render

M.open = open.open

return M
