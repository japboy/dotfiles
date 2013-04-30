" Vim settings for auto-detection of file types

augroup filetypedetect
autocmd BufNewFile,BufRead *.ctp setfiletype php
autocmd BufNewFile,BufRead *.php setfiletype php
augroup END
