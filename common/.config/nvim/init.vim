"
" NEOVIM CONFIGURATION

if &compatible
  set nocompatible
endif

if has('nvim')
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif


""
" Dein.vim
" https://github.com/Shougo/dein.vim

let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  call dein#add('Shougo/vimproc.vim', {'build' : 'make'})

  let s:dein_toml = expand('$XDG_CONFIG_HOME/nvim/dein.toml')
  let s:dein_lazy_toml = expand('$XDG_CONFIG_HOME/nvim/dein_lazy.toml')

  call dein#load_toml(s:dein_toml, {'lazy': 0})
  call dein#load_toml(s:dein_lazy_toml, {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

if dein#check_install()
  call dein#install()
endif


""
" Basic settings

filetype indent on
filetype plugin indent on

"scriptencoding utf-8

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
set listchars=tab:>-,trail:~

set foldmethod=syntax

set laststatus=2
set statusline=%t%m%r%=%{'enc=['.(&fenc!=''?&fenc:&enc).']\ bomb=['.(&bomb?'true':'false').']\ ff=['.&ff.']'}

"language c
"let $LANG='ja_JP.UTF-8'

set nobomb              " Turn BOM off
set encoding=utf-8      " Set default encoding as UTF-8
set fileformat=unix     " Set line-feed as line break
set fileencodings=iso-2022-jp,cp932,sjis,euc-jp,utf-8  " Detect encoding
set fileformats=dos,mac,unix  " Detect line break

"set printoptions=number:y,wrap:y,top:10mm,bottom:10mm,left:10mm,right:10m
"set printencoding=utf-8
"set printmbcharset=JIS_X_1990
"set printmbfont=r:Hiragino_Maru_Gothic_Pro
"set printexpr

"set spell spelllang=en_gb

set backspace=indent,eol,start

"set ambiwidth=double

set scrolloff=5         " Set scroll top position to line 5

" Let NeoVim choose Python runtime wisely
let g:python3_host_prog = expand('$HOME') . '/.anyenv/envs/pyenv/shims/python'

" The Silver Searcher
" https://github.com/ggreer/the_silver_searcher
let g:ackprg = 'ag --vimgrep'


""
" My shorthands

"nmap n nzz
"nmap N Nzz
"nmap * *zz
"nmap # #zz
"nmap g* g*zz
"nmap g# g#zz

"nnoremap <ESC><ESC> :nohlsearch<CR>
nnoremap <C-.> :bnext<CR>
nnoremap <C-,> :bprevious<CR>


""
" Color scheme & highlight

set termguicolors

let g:solarized_termcolors=256  " Enable Solarized colour theme
let g:solarized_termtrans=1

if has('gui_running')
    set background=dark
else
    set background=light
endif

syntax enable
colorscheme solarized

" Highlight characters over 80 chars
set colorcolumn=80
"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"match OverLength /\%81v.\+/

highlight SpecialKey ctermbg=NONE ctermfg=NONE guibg=NONE guifg=#DDDDDD

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
" deoplete & autocomplete
" https://github.com/Shougo/deoplete.nvim

let g:deoplete#enable_at_startup = 1

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
autocmd FileType cs setlocal omnifunc=OmniSharp#Complete


""
" denite
" https://github.com/Shougo/denite.nvim

let g:denite_enable_ignore_case = 1
let g:denite_enable_smart_case = 1

"if executable('ag')
"  let g:denite_source_grep_command = 'ag'
"  let g:denite_source_grep_default_opts = '--nogroup --nocolor --column'
"  let g:denite_source_grep_recursive_opt = ''
"endif

nnoremap <silent> ,g  :<C-u>Denite grep:. -buffer-name=search-buffer<CR>
nnoremap <silent> ,f  :<C-u>Denite file_rec:. -buffer-name=search-buffer<CR>
nnoremap <silent> ,cg :<C-u>Denite grep:. -buffer-name=search-buffer<CR><C-R><C-W><CR>
vnoremap /g y:Denite grep::-iHRn:<C-R>=escape(@", '\\.*$^[]')<CR><CR>


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
let g:syntastic_enable_signs = 1

let g:syntastic_css_checkers = ['stylelint']
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_coffee_coffeelint_args = '--reporter csv --file .coffeelintrc'


""
" vim-tempalte
" https://github.com/aperezdc/vim-template

let g:templates_no_builtin_templates = 1
let g:templates_directory = ['~/.config/nvim/templates']


""
" vim-airline
" https://github.com/vim-airline/vim-airline

let g:airline_powerline_fonts=1
let g:airline#extensions#tabline#enabled = 1
