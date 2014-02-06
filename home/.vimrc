" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=100 " Keep more history, default is 20

set rtp+=~/.vim/bundle/neobundle.vim
call neobundle#rc(expand('~/.vim/bundle/'))

" Vundle
NeoBundleFetch 'Shougo/neobundle.vim'

" Utility
NeoBundle 'Sirupsen/vim-execrus'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'teoljungberg/vim-grep'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-rake'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'wincent/Command-T', {
  \ 'build' : {
    \'mac' : 'ruby ruby/command-t/extconf.rb && make clean && make',
    \'linux' : 'ruby ruby/command-t/extconf.rb && make clean && make' 
  \} 
\}

" Environments
NeoBundle 'derekwyatt/vim-scala'
NeoBundle 'jnwhiteh/vim-golang'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'tpope/vim-liquid'
NeoBundle 'tpope/vim-markdown'
NeoBundle 'tpope/vim-rails'
NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'vim-scripts/VimClojure'

" Colors
NeoBundle 'altercation/vim-colors-solarized'

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
" set autoindent " Indent at the same level as previous line
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
autocmd BufNewFile,BufRead *.rbb set filetype=ruby

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

map <leader>n :NERDTreeToggle<CR>
map <C-t> :CommandT<CR>
map <C-g> :CommandTBuffer<CR>
map <C-7> :CommandTTag<CR>
let g:CommandTAcceptSelectionSplitMap='<C-x>'
let g:CommandTMaxHeight=20

" Auto-format Go, requires vim golang
autocmd BufWrite *.go :Fmt

set wildignore+=.git/**,public/assets/**,vendor/**,log/**,tmp/**,Cellar/**,app/assets/images/**,_site/**,home/.vim/bundle/**,pkg/**,**/.gitkeep,**/.DS_Store,**/*.netrw*,node_modules/*

" netrw tree style listing
let g:netrw_liststyle=3
let g:netrw_banner=0
let g:netrw_winsize=80
