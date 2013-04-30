" Vim settings for LiveScript

" Override indentation settings
setlocal expandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2

" Fold by indentation
" `zi` to toggle folding
setlocal foldmethod=indent nofoldenable

" Run :make when :w is triggered
" depending on vim-coffee-script
"autocmd BufWritePost <buffer> make
