"
" VIM CONFIGURATION

set nocompatible


""
" NeoBundle
" https://github.com/Shougo/neobundle.vim

if has('vim_starting')
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin('~/.vim/bundle/')

" Bundles
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'Shougo/vimproc', {
\   'build' : {
\     'windows' : 'make -f make_mingw32.mak',
\     'cygwin' : 'make -f make_cygwin.mak',
\     'mac' : 'make -f make_mac.mak',
\     'unix' : 'make -f make_unix.mak',
\   },
\ }

NeoBundleLazy 'OmniSharp/omnisharp-vim', {
\   'autoload': { 'filetypes': [ 'cs', 'csi', 'csx' ] },
\   'build': {
\     'windows' : 'msbuild server/OmniSharp.sln',
\     'mac': 'xbuild server/OmniSharp.sln',
\     'unix': 'xbuild server/OmniSharp.sln',
\   },
\ }

NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'aperezdc/vim-template'
NeoBundle 'editorconfig/editorconfig-vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'Shougo/neocomplete.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/vimshell'
NeoBundle 'sjl/gundo.vim'
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'tpope/vim-dispatch'
NeoBundle 'tpope/vim-surround'

NeoBundleLazy 'alpaca-tc/html5.vim', { 'autoload': { 'filetypes': [ 'html', 'htm' ] } }
NeoBundleLazy 'chase/vim-ansible-yaml', { 'autoload': { 'filetypes': [ 'yaml', 'yml' ] } }
NeoBundleLazy 'digitaltoad/vim-jade', { 'autoload': { 'filetypes': [ 'jade' ] } }
NeoBundleLazy 'elzr/vim-json', { 'autoload': { 'filetypes': [ 'json' ] } }
NeoBundleLazy 'gkz/vim-ls', { 'autoload': { 'filetypes': [ 'ls' ] } }
NeoBundleLazy 'groenewege/vim-less', { 'autoload': { 'filetypes': [ 'less' ] } }
NeoBundleLazy 'hail2u/vim-css3-syntax', { 'autoload': { 'filetypes': [ 'css' ] } }
NeoBundleLazy 'kchmck/vim-coffee-script', { 'autoload': { 'filetypes': [ 'coffee' ] } }
NeoBundleLazy 'kongo2002/fsharp-vim', { 'autoload': { 'filetypes': [ 'fs', 'fsi', 'fsx' ] } }
NeoBundleLazy 'lambdatoast/elm.vim', { 'autoload': { 'filetypes': [ 'elm' ] } }
NeoBundleLazy 'leafgarland/typescript-vim', { 'autoload': { 'filetypes': [ 'ts' ] } }
NeoBundleLazy 'mintplant/vim-literate-coffeescript', { 'autoload': { 'filetypes': [ 'coffee' ] } }
NeoBundleLazy 'mxw/vim-jsx', { 'autoload': { 'filetypes': [ 'js' ] } }
NeoBundleLazy 'nono/vim-handlebars', { 'autoload': { 'filetypes': [ 'hbs' ] } }
NeoBundleLazy 'nvie/vim-flake8', { 'autoload': { 'filetypes': [ 'py' ] } }
NeoBundleLazy 'OrangeT/vim-csharp', { 'autoload': { 'filetypes': [ 'cs', 'csi', 'csx' ] } }
NeoBundleLazy 'pangloss/vim-javascript', { 'autoload': { 'filetypes': [ 'js' ] } }
NeoBundleLazy 'tikhomirov/vim-glsl', { 'autoload': { 'filetypes': [ 'frag', 'vert' ] } }
NeoBundleLazy 'tpope/vim-haml', { 'autoload': { 'filetypes': [ 'haml' ] } }
NeoBundleLazy 'wavded/vim-stylus', { 'autoload': { 'filetypes': [ 'styl' ] } }

call neobundle#end()


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
let g:solarized_termtrans=1

if has('gui_running')
    set background=light
else
    set background=dark
endif

" Highlight characters over 80 chars
set colorcolumn=80
"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"match OverLength /\%81v.\+/

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
  elseif has("gui_vimr")
    set guifont=Sauce_Code_Powerline:h11
    set guifontwide=Sauce_Code_Powerline:h11
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
" neocomplete
" https://github.com/Shougo/neocomplete.vim
" https://github.com/OmniSharp/omnisharp-vim/wiki/Example-NeoComplete-Settings

let g:acp_enableAtStartup = 0
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif

let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.cs = '.*[^=\);]'


""
" NERDTree
" https://github.com/scrooloose/nerdtree

let g:NERDTreeShowBookmarks=1
autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd w
autocmd BufEnter * NERDTreeMirror


""
" syntastic
" https://github.com/scrooloose/syntastic

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


""
" Unite.vim
" https://github.com/Shougo/unite.vim

let g:unite_enable_start_insert = 1
let g:unite_enable_ignore_case = 1
let g:unite_enable_smart_case = 1

nnoremap <silent> ,g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
nnoremap <silent> ,cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
nnoremap <silent> ,r  :<C-u>UniteResume search-buffer<CR>

if executable('pt')
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor'
  let g:unite_source_grep_recursive_opt = ''
endif


""
" vim-tempalte
" https://github.com/aperezdc/vim-template

let g:templates_no_builtin_templates = 1
let g:templates_directory = ['~/.vim/templates']
