au BufNewFile,BufRead *.kors :set filetype=korsakov
au BufNewFile,BufRead *.корс :set filetype=korsakov
autocmd FileType korsakov set commentstring=!!%s
