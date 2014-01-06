"
" VIM CONFIGURATION

set nocompatible


""
" NeoBundle
" https://github.com/Shougo/neobundle.vim

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#rc(expand('~/.vim/bundle/'))

" Bundles
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'alpaca-tc/html5.vim'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'aperezdc/vim-template'
NeoBundle 'digitaltoad/vim-jade'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'elzr/vim-json'
NeoBundle 'gkz/vim-ls'
NeoBundle 'groenewege/vim-less'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'leafgarland/typescript-vim'
NeoBundle 'mintplant/vim-literate-coffeescript'
NeoBundle 'nono/vim-handlebars'
NeoBundle 'nvie/vim-flake8'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'rizzatti/dash.vim'
NeoBundle 'rizzatti/funcoo.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/vimshell'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'tpope/vim-haml'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'wavded/vim-stylus'


""
" Basic settings

filetype indent on
filetype plugin indent on

scriptencoding utf-8

set number              " Display line number
set wrap

set hlsearch            " Highlight matched search patterns
set incsearch           " Turn incremental search mode on
set ignorecase
set smartcase

set expandtab           " Insert spaces instead of tab
"set noexpandtab         " Insert tab as indent
set tabstop=4           " Display tab as 4 space characters
set shiftwidth=4
set softtabstop=4       " Remove 4 spaces with Backspace key

set list                " Display unprintable characters (eol, tab, etc)
set listchars=tab:..,trail:~

set foldmethod=syntax

set clipboard=unnamed   " Enable to share clipboard with GVim & OS

set laststatus=2
set statusline=%t%m%r%=%{'enc=['.(&fenc!=''?&fenc:&enc).']\ bomb=['.(&bomb?'true':'false').']\ ff=['.&ff.']'}

"language c
"let $LANG='ja_JP.UTF-8'

set nobomb              " Turn BOM off
set encoding=utf-8      " Encode text as UTF-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis  " Encode file as UTF-8
set fileformat=unix     " Set Line Feed as line break

set printoptions=number:y,wrap:y,top:10mm,bottom:10mm,left:10mm,right:10m
set printencoding=utf-8
set printmbcharset=JIS_X_1990
set printmbfont=r:Hiragino_Maru_Gothic_Pro
"set printexpr

"set spell spelllang=en_gb

set backspace=indent,eol,start

set ambiwidth=double


""
" Color scheme & highlight

syntax enable
colorscheme solarized

let g:solarized_termcolors=256  " Enable Solarized colour theme

if has('gui_running')
    set background=light
else
    set background=dark
endif

" Highlight characters over 80 chars
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

" Highlight current line
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END


""
" Folding

let g:vimsyn_folding='af'       " Enable new built-in folding


""
" GUI

if has("gui_running")
  autocmd GUIEnter * winsize 84 35
  set showtabline=2

  if has("gui_gnome")
    set guifont=Monospace\ Normal\ 10
  elseif has("gui_macvim")
    set guifont=Monaco:h12
    set guifontwide=Hiragino_Maru_Gothic_Pro:h12
    set printfont=Monaco:h12:cDEFAULT
  elseif has("gui_win")
    set guifont=Terminal:h10:w5:cANSI
    set guifontwide=Terminal:h10:cSHIFTJIS
    set printfont=MS_Gothic:h10:cDEFAULT
    set shellslash  " / = \
  endif
endif


""
" Powerline
" https://github.com/Lokaltog/powerline

set rtp+=~/.dotfiles/common/opt/powerline/powerline/bindings/vim


""
" neocomplcache
" https://github.com/Shougo/neocomplcache

let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_camel_case_completion = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_min_syntax_length = 3
" buffer file name pattern that locks neocomplcache. e.g. ku.vim or fuzzyfinder
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'

" Define file-type dependent dictionaries.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
    \ }

" Define keyword, for minor languages
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'

" AutoComplPop like behavior.
let g:neocomplcache_enable_auto_select = 1

" Enable omni completion. Not required if they are already set elsewhere in .vimrc
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags


""
" NERDTree
" https://github.com/scrooloose/nerdtree

autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd w
autocmd BufEnter * NERDTreeMirror
