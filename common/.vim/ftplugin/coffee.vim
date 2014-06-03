" Vim settings for CoffeeScript

" Override indentation settings from vim-coffee-script
setlocal expandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2

" Fold by indentation
" `zi` to toggle folding
setlocal foldlevelstart=99
setlocal foldmethod=indent

" Run :make when :w is triggered
" depending on vim-coffee-script
"autocmd BufWritePost <buffer> make
