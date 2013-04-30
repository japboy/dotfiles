" Vim settings for PHP file

" Disable default filetype settings as it inherit HTML indentation settings!
if (exists("b:did_ftplugin"))
    finish
endif
let b:did_ftplugin = 1

setlocal noexpandtab
setlocal tabstop=4
setlocal shiftwidth=4
setlocal softtabstop=4

" Set :make command as `php -l`
set makeprg=php\ -l\ %
set errorformat=%m\ in\ %f\ on\ line\ %l
" Set :make command as PHP_CodeSniffer
"set makeprg=phpcs\ --encoding=utf-8\ %
"set errorformat+="%f"\\,%l\\,%c\\,%t%*[a-zA-Z]\\,"%m"

" Run :make when :w is triggered
autocmd BufWritePost <buffer> make
