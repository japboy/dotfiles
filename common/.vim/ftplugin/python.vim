" Vim settings for Python file

" Override indentation settings
setlocal expandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4

" Run `Flake8()` when `:w` is triggered
autocmd BufWritePost <buffer> call Flake8()
