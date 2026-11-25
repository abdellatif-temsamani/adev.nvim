#!/usr/bin/env bash
# Run the adev-files formatting, syntax and headless regression checks.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/../.."

stylua --check lua/adev-files tests/adev-files
find lua/adev-files tests/adev-files -name '*.lua' -print0 | xargs -0 -n1 luac -p
nvim --headless -u NONE -l tests/adev-files/edge_cases.lua
