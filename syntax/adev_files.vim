if exists("b:current_syntax")
  finish
endif

" keywords
syntax keyword adevKeyword file directory

" colon operator
syntax match adevOps ": "

" value after colon (space optional)
syntax match adevString ":\s\+.*$" contains=adevOps

" highlights
highlight link adevKeyword Keyword
highlight link adevOps Operator
highlight link adevString ColorColumn

let b:current_syntax = "adev_files"

