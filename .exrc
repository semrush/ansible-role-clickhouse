"
" Add this into your .vimrc, to allow vim handle this file.
"
" set exrc
" set secure " even after this this is kind of dangerous
"

set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab

let detectindent_preferred_indent=2
let g:detectindent_preferred_expandtab=1

au BufRead,BufNewFile *.yml.j2  set ft=yaml
au BufRead,BufNewFile *.yaml.j2 set ft=yaml
au BufRead,BufNewFile *.xml.j2  set ft=xml
au BufRead,BufNewFile *.sh.j2   set ft=sh

au BufRead,BufNewFile .ansible-lint set ft=yaml
