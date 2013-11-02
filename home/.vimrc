" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=100 " Keep more history, default is 20

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vundle
Bundle 'gmarik/vundle'

" Utility
Bundle 'teoljungberg/vim-grep'
Bundle 'Sirupsen/vim-execrus'
Bundle 'wincent/Command-T'
Bundle 'tomtom/tcomment_vim'
Bundle 'tpope/vim-fugitive'
Bundle 'tpope/vim-endwise'
Bundle 'tpope/vim-surround'
Bundle 'tpope/vim-rake'
Bundle 'scrooloose/nerdtree'
Bundle 'scrooloose/syntastic'
Bundle 'tpope/vim-unimpaired'

" Environments
Bundle 'pangloss/vim-javascript'
Bundle 'kchmck/vim-coffee-script'
Bundle 'vim-ruby/vim-ruby'
Bundle 'tpope/vim-liquid'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-rails'
Bundle 'vim-scripts/VimClojure'
Bundle 'jnwhiteh/vim-golang'
Bundle 'derekwyatt/vim-scala'

" Colors
Bundle 'altercation/vim-colors-solarized'

" Enable after Vundle.. in the README,
" dunno what happens if you don't do this.
filetype plugin indent on

" BACKUP
set noswapfile
set nobackup
" Allow editing crontabs http://vim.wikia.com/wiki/Editing_crontab
set backupskip=/tmp/*,/private/tmp/* "
set undodir=~/.vim/undo

" PRETTY COLORS
syntax enable
colorscheme solarized
set background=dark " Set dark solarized theme
set t_Co=256 " 256 colors

set textwidth=80 " Switch line at 80 characters
set scrolloff=5 " Keep some distance to the bottom"

set showmatch " Show matching of: () [] {}

" SEARCHING
set ignorecase " Required for smartcase to work
set smartcase " Case sensitive when uppercase is present
set incsearch " Search as you type

" FORMATTING
set autoindent " Indent at the same level as previous line
set smartindent
set smarttab
set expandtab " Tabs are spaces

set tabstop=2 " Tabs are 2 spaces
set backspace=2 " Backspace back 2 spaces
set shiftwidth=2 " Even if there are tabs, preview as 2 spaces

" KEY MAPPING
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l
map <C-H> <C-W>h

imap jk <esc>
map <leader>d :bd<CR>
map <leader>cd :cd %:p:h<CR>

" K and J behaves as expected for long lines.
nmap k gk
nmap j gj

" Easier to type
noremap H ^
noremap L $

" Enable spelling in Markdown
autocmd BufNewFile,BufRead *.md,*.markdown set spell

" PLUGINS

" Fugitive
map <leader>gs :Gstatus<CR>
map <leader>gc :Gcommit<CR>

" Rename current file, thanks Gary Bernhardt via Ben Orenstein
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name != old_name
    exec ':saveas ' . new_name
    exec ':silent !rm ' . old_name
    redraw!
  endif
endfunction

map <leader>r :call RenameFile()<cr>

" Sane default tab-key, I basically used
" Supertab for this functionality before, but this is all I need.
" Stolen from Gary Bernhardt's Vim config
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction

imap <tab> <c-r>=InsertTabWrapper()<cr>
imap <s-tab> <c-n>

map <C-E> :call g:Execrus()<CR>
map <C-\> :call g:Execrus('alternative')<CR>
map <C-P> :call g:Execrus('repl')<CR>

" Ctag options
set tags=tags,gems.tags " Since i ctag for gems

" Force vim to use login shell, ie. for chruby to work right.
" https://github.com/postmodern/chruby/wiki/Vim
set shell=$SHELL\ -l

" Only force ag if it actually exists, otherwise fall back to `git grep` which
" is the default.
if executable("ag")
  let g:grepprg="ag --nogroup --column"
endif

map <leader>n :NERDTreeToggle<CR>
map <C-t> :CommandT<CR>
map <C-g> :CommandTBuffer<CR>
map <C-7> :CommandTTag<CR>
let g:CommandTAcceptSelectionSplitMap='<C-x>'
let g:CommandTMaxHeight=20

" Auto-format Go, requires vim golang
autocmd BufWrite *.go :Fmt

set wildignore+=.git/**,public/assets/**,vendor/**,log/**,tmp/**,Cellar/**,app/assets/images/**,_site/**,home/.vim/bundle/**,pkg/**,**/.gitkeep,**/.DS_Store,**/*.netrw*
