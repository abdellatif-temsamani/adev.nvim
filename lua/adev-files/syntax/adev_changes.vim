if exists("b:current_syntax")
  finish
endif

syntax match adevChangesSection "^Staged ops:\|^Planned ops:"
syntax match adevChangesOp "\v^\s+(move|copy|rename|delete|create)\s"
syntax match adevChangesArrow " -> "
syntax match adevChangesNone "(no pending changes)"

highlight link adevChangesSection Title
highlight link adevChangesOp Identifier
highlight link adevChangesArrow Special
highlight link adevChangesNone Comment

let b:current_syntax = "adev_changes"
