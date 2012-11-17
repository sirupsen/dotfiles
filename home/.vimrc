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
map <leader>d :bd<CR>

" PLUGINS

" CtrlP.vim
let g:ctrlp_map = '<c-t>'
" Set working directory to nearest ancester that has a .git directory
let g:ctrlp_working_path_mode = 2
  
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

" K and J behaves as expected for long lines.
nmap k gk
nmap j gj

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
