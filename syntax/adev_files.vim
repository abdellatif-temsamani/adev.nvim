if exists("b:current_syntax")
  finish
endif

" keywords
syntax keyword adevFilesKeyword file directory

" colon operator
syntax match adevFilesOps ": "

" value after colon (space optional)
syntax match adevFilesString ":\s\+.*$" contains=adevOps
syntax match adevFilesTitle "root: .*"

" highlights
highlight link adevFilesKeyword Keyword
highlight link adevFilesOps Operator
highlight link adevFilesString Pmenu
highlight link adevFilesTitle Directory

let b:current_syntax = "adev_files"

