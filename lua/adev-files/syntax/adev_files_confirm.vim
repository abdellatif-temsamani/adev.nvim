" Adev Files confirmation window syntax
" Enhanced syntax highlighting for file operations

if exists("b:current_syntax")
  unlet b:current_syntax
endif

" Load base syntax
silent! runtime lua/adev-files/syntax/adev_files.vim

" Clear old operation patterns (silently ignore if they don't exist)
silent! syntax clear adevFilesOp
silent! syntax clear adevFilesOpValue

" Operation keywords - each with distinct semantic color
syn match adevFilesCreate "^create:" contained
syn match adevFilesDelete "^delete:" contained
syn match adevFilesRename "^rename:" contained
syn match adevFilesCopy   "^copy:"   contained
syn match adevFilesMove   "^move:"   contained

" Arrow separator for rename/copy/move operations
syn match adevFilesArrow " -> " contained

" Paths - source and destination
syn match adevFilesPath ":\s*\zs\S.*$" contained
syn match adevFilesSrcPath ":\s*\zs.\{-}\ze\s*->" contained
syn match adevFilesDstPath "->\s*\zs.*$" contained

" Full operation lines with contained patterns
syn match adevFilesCreateLine "^create:.*$" contains=adevFilesCreate,adevFilesPath
syn match adevFilesDeleteLine "^delete:.*$" contains=adevFilesDelete,adevFilesPath
syn match adevFilesRenameLine "^rename:.*$" contains=adevFilesRename,adevFilesArrow,adevFilesSrcPath,adevFilesDstPath
syn match adevFilesCopyLine   "^copy:.*$"   contains=adevFilesCopy,adevFilesArrow,adevFilesSrcPath,adevFilesDstPath
syn match adevFilesMoveLine   "^move:.*$"   contains=adevFilesMove,adevFilesArrow,adevFilesSrcPath,adevFilesDstPath

" Footer line (y/<CR>: confirm, etc)
syn match adevFilesFooter "^[yn</].*$"

" Highlight groups with semantic colors
highlight default link adevFilesCreate  DiagnosticOk
highlight default link adevFilesDelete  DiagnosticError
highlight default link adevFilesRename  DiagnosticWarn
highlight default link adevFilesCopy    DiagnosticInfo
highlight default link adevFilesMove    DiagnosticHint
highlight default link adevFilesArrow   Operator
highlight default link adevFilesPath    String
highlight default link adevFilesSrcPath Comment
highlight default link adevFilesDstPath String
highlight default link adevFilesFooter  Comment

let b:current_syntax = "adev_files_confirm"
