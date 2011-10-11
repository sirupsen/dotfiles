" A lot stolen from 'The Ultimate .Vimrc File'
" http://spf13.com/post/ultimate-vim-config
"

" Setup Bundle Support {
  call pathogen#runtime_append_all_bundles()
" }

" Basics {
  set nocompatible " No vi compatility
  let mapleader="," " Mapleader
" }

" General {
  filetype plugin indent on " Automatically change file types.

  "set autochdir " Automatically always switch to the current files directory.
  set shortmess=filmnrxoOtT      " abbrev. of messages (avoids 'hit enter')
  set history=1000 " Keep (a lot) more history

  " No needs for backups, I have Git for that
  set noswapfile 
  set nobackup

  " 80 columns
  set textwidth=80
" }

" Vim UI {
  syntax enable " Enable syntax highlightation.¨
  colorscheme solarized " Default colorscheme
  set background=dark

  set t_Co=256 " Terminal colors

  set ruler " Enable cursor position
  set showcmd  " Show incomplete CMDS at the bottom
  
  set showmatch " Show matching of: () [] {}

  " Searching {
    set ignorecase " Case insensitive search
    set smartcase " Case sensitive when uppercase is present
    set incsearch " Search as you type
    "set hlsearch " Highlight search matches
  " }

  set autoread " Auto read when file is changed

  set hidden " Hide buffers, rather than close them

  set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
" }

  " Formatting {
  " Be smart, and awesome, about indentation
  set autoindent " Indent at the same level as previous line
  set smartindent
  set smarttab
  set expandtab " Tabs are spaces

  set tabstop=2 " Tabs are 2 spaces
  set backspace=2 " Backspace back 2 spaces
  set shiftwidth=2 " Even if there are tabs, preview as 2 spaces
" }

" Key Mapping {
  map <S-C-J> <C-W>j<C-W>_
  map <S-C-K> <C-W>k<C-W>_
  map <S-C-L> <C-W>l<C-W>_
  map <S-C-H> <C-W>h<C-W>_
  map <S-C-K> <C-W>k<C-W>_
  map <C-J> <C-W>j
  map <C-K> <C-W>k
  map <C-L> <C-W>l
  map <C-H> <C-W>h
  map <C-K> <C-W>k
  map <S-H> gT
  map <S-L> gt

  " Use jk as escape
  inoremap jk <esc>

  " Shift key fixes
  cmap W w
  cmap WQ wq
  cmap wQ wq
  cmap Q q

  " Key mappings
  :noremap ,d :bd<CR>

  " Make keys work as expected for wrapped lines
  inoremap <Down> <C-o>gj
  inoremap <Up> <C-o>gk
" }


" Plugins {
  " NerdTree {
    let NERDTreeChDirMode = 1
    let NERDTreeWinSize=20

    :noremap ,n :NERDTreeToggle<CR>
  " }

  " Gist {
    let g:gist_clip_command = 'pbcopy'
    let g:gist_detect_filetype = 1
    let g:gist_open_browser_after_post = 1
  " }

  " Delimitmate {
    au FileType * let b:delimitMate_autoclose = 1
  " }

  " SnipMate {
    " Author var
    let g:snips_author = 'Simon Hørup Eskildsen <<a class="linkclass" href="mailto:sirup@sirupsen.com">sirup@sirupsen.com</a>>'
  " }

  " Jekyll {
    let g:jekyll_path = "~/code/projects/sirupsen.com"
    let g:jekyll_post_suffix = "md"
  " }
  
  " VimRoom {
  " }

  " Fugitive {
    map <Leader>gc :Gcommit<CR>
    map <Leader>gs :Gstatus<CR>
  " }

  " Tabular {
    if exists(":Tab")
      nmap <Leader>t= :Tab /=<CR>
      nmap <Leader>t= :Tab /=<CR>
      vmap <Leader>t> :Tab /=><CR>
      vmap <Leader>t> :Tab /=><CR>
      nmap <Leader>t: :Tab /:\zs<CR>
      vmap <Leader>t: :Tab /:\zs<CR>
    endif
  " }

  " Command-T {
    nmap <Leader>f :CommandTFlush<CR>
    nmap <C-T> :CommandT<CR>
  " }

  " Rainbow {
    runtime plugin/RainbowParenthsis.vim 
  " }
