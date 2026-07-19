if exists("b:current_syntax")
  finish
endif

" Title line
syntax match adevFilesHelpTitle "^  adev-files$"

" Section headers
syntax match adevFilesHelpSection "^  \w\+\ze$"

" Keybindings
syntax match adevFilesHelpKey "\S\+\ze\s\{2,\}"

" Description text (after 2+ spaces of indent following key)
syntax match adevFilesHelpDesc "\(\s\{4,\}\)\@<=.\+"

" Highlight groups
highlight link adevFilesHelpTitle Title
highlight link adevFilesHelpSection Statement
highlight link adevFilesHelpKey Identifier
highlight link adevFilesHelpDesc Comment

let b:current_syntax = "adev_files_help"
