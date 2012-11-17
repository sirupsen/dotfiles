call pathogen#infect() " Setup Bundle Support

" BASIC
set nocompatible " No vi compatility
let mapleader="," " Mapleader
filetype plugin indent on " Automatically change file types
set encoding=utf-8
set history=1000 " Keep (a lot) more history

" BACKUP
set noswapfile 
set nobackup
set backupskip=/tmp/*,/private/tmp/* " Allow editing crontabs http://vim.wikia.com/wiki/Editing_crontab

" PRETTY COLORS
syntax enable
colorscheme solarized
set background=dark " Set dark solarized theme
set t_Co=256 " 256 colors

set textwidth=80 " Switch line at 80 characters
set scrolloff=5 " Keep some distance to the bottom"

set showmatch " Show matching of: () [] {}

" SEARCHING
set ignorecase " Case insensitive search
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
map <C-K> <C-W>k

inoremap jk <esc>
nnoremap <leader>d :bd<CR>

" PLUGINS

" NerdTree.vim
let NERDTreeChDirMode = 1
let NERDTreeWinSize=20

let NERDTreeHighlightCursorline=1
nnoremap ,n :NERDTreeToggle<CR>

" Gist.vim
let g:gist_clip_command = 'pbcopy'
let g:gist_detect_filetype = 1
let g:gist_open_browser_after_post = 0

" CtrlP.vim
let g:ctrlp_map = '<c-t>'
" Set working directory to nearest ancester that has a .git directory
let g:ctrlp_working_path_mode = 2
  
" Fugitive
nnoremap <leader>gs :Gstatus<CR>
nnoremap <leader>gc :Gcommit<CR>

" Tabular {
nmap <Leader>t= :Tab /=<CR>
nmap <Leader>t= :Tab /=<CR>
vmap <Leader>t> :Tab /=><CR>
vmap <Leader>t> :Tab /=><CR>
nmap <Leader>t: :Tab /:\zs<CR>
vmap <Leader>t: :Tab /:\zs<CR>

" Be nice to long lines
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$
