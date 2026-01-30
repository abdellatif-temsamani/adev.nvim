if exists("b:current_syntax")
  finish
endif

" ============================================================
" Adev Files Syntax Highlighting
" Format: help | ==== | root: <path> | name (directories end with /)
" ============================================================

" Help line (first line with keybindings)
syntax match adevFilesHelp "^<CR>.*$"

" Separator line (====)
syntax match adevFilesSeparator "^=\+$"

" Directories - lines ending with / (defined first so root: can override)
syntax match adevFilesDirValue "^.\+/$"

" Root title line (defined after to take precedence over directory match)
syntax match adevFilesTitle "^root:.*$"

" Files - lines NOT starting with root: and NOT ending with /
syntax match adevFilesFileValue "^[^r].*[^/]$"
syntax match adevFilesFileValue "^r[^o].*[^/]$"
syntax match adevFilesFileValue "^ro[^o].*[^/]$"
syntax match adevFilesFileValue "^roo[^t].*[^/]$"
syntax match adevFilesFileValue "^root[^:].*[^/]$"

" ============================================================
" Highlight Groups
" ============================================================

" Help line - subtle color
highlight link adevFilesHelp Comment

" Separator - subtle
highlight link adevFilesSeparator Comment

" Root title - distinct bold color for visibility
highlight default link adevFilesTitle Type
highlight default adevFilesTitle gui=bold cterm=bold

" Directories - using Function for visibility
highlight link adevFilesDirValue Function

" Files - using Normal (default text color)
highlight link adevFilesFileValue Normal

let b:current_syntax = "adev_files"
