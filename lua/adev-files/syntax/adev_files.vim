if exists("b:current_syntax")
  finish
endif

" ============================================================
" Adev Files Syntax Highlighting
" Format: help | ==== | root: <path> | name (directories end with /)
" ============================================================

" Compact help bar lines — keybindings
syntax match adevFilesHelp "^│.*$" contains=adevFilesHelpKey

" Key tokens within help bar
syntax match adevFilesHelpKey "\c<CR>" contained containedin=adevFilesHelp
syntax match adevFilesHelpKey "\c<bs>" contained containedin=adevFilesHelp
syntax match adevFilesHelpKey "[=?]" contained containedin=adevFilesHelp
syntax match adevFilesHelpKey "ny" contained containedin=adevFilesHelp
syntax match adevFilesHelpKey "nx" contained containedin=adevFilesHelp
syntax match adevFilesHelpKey "np" contained containedin=adevFilesHelp
syntax match adevFilesHelpKey "nd" contained containedin=adevFilesHelp
syntax match adevFilesHelpKey "nc" contained containedin=adevFilesHelp

" Separator line (====)
syntax match adevFilesSeparator "^=\+$"

" Directories - lines ending with / (defined first so root: can override)
syntax match adevFilesDirValue "^.\+/$"

" Root title line (defined after to take precedence over directory match)
syntax match adevFilesTitle "^root:.*$"

" Group separator (blank lines between sections)
syntax match adevFilesGroupSep "^$"

" Files - lines not starting with root:, │, =; not ending with /
syntax match adevFilesFileValue "^[^r│=].*[^/]$"
syntax match adevFilesFileValue "^r[^o].*[^/]$"
syntax match adevFilesFileValue "^ro[^o].*[^/]$"
syntax match adevFilesFileValue "^roo[^t].*[^/]$"
syntax match adevFilesFileValue "^root[^:].*[^/]$"

" ============================================================
" Highlight Groups
" ============================================================

" Help line - subtle color
highlight link adevFilesHelp Comment

" Help keys - stand out from descriptions
highlight link adevFilesHelpKey Identifier

" Separator - subtle
highlight link adevFilesSeparator Comment

" Group separator (blank line between dirs and files)
highlight link adevFilesGroupSep Comment

" Root title - distinct bold color for visibility
highlight default link adevFilesTitle Type
highlight default adevFilesTitle gui=bold cterm=bold

" Directories - using Function for visibility
highlight link adevFilesDirValue Function

" Files - using Normal (default text color)
highlight link adevFilesFileValue Normal

" Pending ops (virtual inline markers)
highlight default link adevFilesPendingDelete DiffDelete
highlight default link adevFilesPendingCopy DiffAdd
highlight default link adevFilesPendingMove DiffChange
highlight default adevFilesPendingCopy gui=bold cterm=bold
highlight default adevFilesPendingMove gui=bold cterm=bold

let b:current_syntax = "adev_files"
