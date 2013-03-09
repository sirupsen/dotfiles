" BASIC
set nocompatible " No vi compatility
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=100 " Keep more history

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vundle
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-endwise'
Bundle 'mileszs/ack.vim'
Bundle 'kchmck/vim-coffee-script'
Bundle 'kien/ctrlp.vim'
Bundle 'tpope/vim-fugitive'
Bundle 'mattn/gist-vim'
Bundle 'pangloss/vim-javascript'
Bundle 'tpope/vim-liquid'
Bundle 'tpope/vim-markdown'
Bundle 'tpope/vim-rails'
Bundle 'vim-ruby/vim-ruby'
Bundle 'altercation/vim-colors-solarized'
Bundle 'tpope/vim-surround'
Bundle 'godlygeek/tabular'
Bundle 'tomtom/tcomment_vim'
Bundle 'mattn/webapi-vim'
Bundle 'sirupsen/vim-execrus'

" Enable after Vundle.. in the README,
" dunno what happens if you don't do this.
filetype plugin indent on

" Warn trailing whitespace, thx @metamorfos
set list
set listchars=tab:>-,trail:.,extends:❯,precedes:❮

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
set sidescrolloff=5

set showmatch " Show matching of: () [] {}

" SEARCHING
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
vmap k gk
vmap k gk

" PLUGINS

" Ctrlp
let g:ctrlp_map = '<c-t>'
let g:ctrlp_working_path_mode = 2 " Be smart about working dir

" Fugitive
map <leader>gs :Gstatus<CR>
map <leader>gc :Gcommit<CR>

" Tabular {
map <Leader>t= :Tab /=<CR>
map <Leader>t= :Tab /=<CR>
map <Leader>t> :Tab /=><CR>
map <Leader>t> :Tab /=><CR>
map <Leader>t: :Tab /:\zs<CR>
map <Leader>t: :Tab /:\zs<CR>

" :so ~/.vim/execrus.vim

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

set completeopt-=preview
map <F8> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

map <C-E> :call g:Execrus()<CR>
map <C-\> :call g:Execrus('walrus')<CR>
