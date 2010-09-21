"
"
" @Docs:
" http://biodegradablegeek.com/2007/12/using-vim-as-a-complete-ruby-on-rails-ide/
"

call pathogen#runtime_append_all_bundles()

set nocompatible " No vi compatility
autocmd BufEnter * :syntax sync fromstart

" Mapleader
let mapleader=","

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" Matching
set sm
set matchpairs+=<:> " html

" Tab settings
set sw=2
set sts=2
set ts=2 " Tabs are 2 spaces
set bs=2 " Backspaces are 2 spaces
set shiftwidth=2 " Tabs

set autoindent
set smartindent
set smarttab
set expandtab

" Hello, Git
set noswapfile
set nobackup

set autoread " Auto read when file is changed
set showmatch " Show matching brackets

" Hide buffers, rather than close them
set hidden

set shortmess=atI

set ruler " Enable cursor position
set history=1000 " Keep more history
set undolevels=1000 " .. and a lot of undoing!

set ignorecase " case only matters with regex, else we have smartcase
set smartcase " ignore case if all lowercase, else: case-sensitive

set showcmd  " Show incomplete CMDS at the bottom
set showmode " Show current mode at the bottom
set linebreak " Crap at convenient points
set incsearch " Search as you type

" GVIM
set guioptions-=m " Remove menu bar
set guioptions-=T " Remove toolbar with icons
set guioptions-=r " Remove scrollbars (http://vimdoc.sourceforge.net/htmldoc/options.html#%27guioptions%27)
set guioptions-=l
set guioptions-=L

" 256 color
set t_Co=256

" Default color scheme
syntax on
colorscheme mustang

" Default Nerdtree configuration
let NERDTreeChDirMode = 1
let NERDTreeWinSize=20

" Dir
set browsedir=buffer

" Set the font :)
set gfn=Monaco\ 9

" Set filetype stuff `on` 
filetype on
filetype plugin on
filetype indent on

" Only in gVim
if has("gui_running")
  " Autoload NERDTree in Gui
  autocmd VimEnter * NERDTree ~/Dropbox/Code
	autocmd VimEnter * NERDTree ~/Code
  " Default lines, columns as well as default position for gVim
  set lines=65
  set columns=115
  winpos 1295 30
  colorscheme railscasts
endif

" Nice title
if has('title') && (has('gui_running') || &title)
    set titlestring=
	set titlestring+=%f\                                              " file name
	set titlestring+=%h%m%r%w                                         " flags
	set titlestring+=\ -\ %{v:progname}                               " program name
	set titlestring+=\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}  " working directory
endif

" Nice markdown behavior
augroup mkd
  autocmd BufRead *.mkd  set ai formatoptions=tcroqn2 comments=n:&gt;
augroup END

" Key mappings
:noremap ,n :NERDTreeToggle<CR>
:noremap ,d :bd<CR>
cmap w!! w !sudo tee

" Filetypes for special files
"au BufNewFile,BufRead *.j                       setf objj 
"au BufNewFile,BufRead *.js                      setf javascript 
"au BufNewFile,BufRead *.rb                      setf ruby 
"au BufNewFile,BufRead *.coffee                  setf coffee

if has("autocmd")
  " Restore cursor position
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
endif

map ,c :cd %:p:h<CR>

" Save when losing focus
au FocusLost * :wa

" Gist
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 1
