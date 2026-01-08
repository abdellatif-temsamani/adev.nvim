if exists("b:current_syntax")
  finish
endif

" ============================================================
" Adev Files Syntax Highlighting
" Format: root: <path> | file: <name> | directory: <name>
" ============================================================

" Keywords - separate colors for file and directory
syntax keyword adevFilesFile file
syntax keyword adevFilesDirectory directory

" Root title line (distinct from directories)
syntax match adevFilesTitle "^root:.*$"

" Colon operator for key-value separator
syntax match adevFilesSeparator contained ":\s*"

" Values after keywords (after the colon and optional whitespace)
syntax match adevFilesFileValue "file:\s*\zs.*" contains=adevFilesSeparator
syntax match adevFilesDirValue "directory:\s*\zs.*" contains=adevFilesSeparator

" Special characters in paths (/, \, ., -, _, space, etc.)
syntax match adevFilesSpecial contained "[/\\._-]"

" Quoted strings (for paths with special characters)
syntax region adevFilesQuote start=+"+ end=+"+ contained
syntax region adevFilesQuote start=+'+ end=+'+ contained

" ============================================================
" Highlight Groups
" ============================================================

" Keywords - different colors for file vs directory
highlight link adevFilesFile Function
highlight link adevFilesDirectory Comment

" Root title - distinct bold color for visibility
highlight default link adevFilesTitle Type
highlight default adevFilesTitle gui=bold cterm=bold

" Separator - colon operator
highlight link adevFilesSeparator Operator

" Values - strings for paths/filenames
highlight link adevFilesFileValue String
highlight link adevFilesDirValue String

" Special characters - subtle differentiation in paths
highlight link adevFilesSpecial Special

" Quoted strings - same as values but explicit
highlight link adevFilesQuote String

let b:current_syntax = "adev_files"

