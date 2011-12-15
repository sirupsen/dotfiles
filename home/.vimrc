" A lot stolen from 'The Ultimate .Vimrc File'
" http://spf13.com/post/ultimate-vim-config
"

" Setup Bundle Support {
  call pathogen#infect()
" }

" Basics {
  set nocompatible " No vi compatility
  let mapleader="," " Mapleader

  set encoding=utf-8

  filetype plugin indent on " Automatically change file types.

  "set autochdir " Automatically always switch to the current files directory.
  set shortmess=filmnrxoOtT      " abbrev. of messages (avoids 'hit enter')
  set history=1000 " Keep (a lot) more history

  " No needs for backups, I have Git for that
  set noswapfile 
  set nobackup
" }

" Vim UI {
  syntax enable
  colorscheme solarized
  set background=dark
  set t_Co=256 
  set textwidth=80
  set scrolloff=3
  set ruler
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
" }

" Statusline {
  " augroup ft_statuslinecolor
  "   au!

  "   au InsertEnter * hi StatusLine ctermfg=196 guifg=#FF3145
  "   au InsertLeave * hi StatusLine ctermfg=130 guifg=#CD5907
  " augroup END

  " set statusline=%f    " Path.
  " set statusline+=%m   " Modified flag.
  " set statusline+=%r   " Readonly flag.
  " set statusline+=%w   " Preview window flag.

  " set statusline+=\    " Space.

  " set statusline+=%#redbar#                " Highlight the following as a warning.
  " set statusline+=%{SyntasticStatuslineFlag()} " Syntastic errors.
  " set statusline+=%*                           " Reset highlighting.

  " set statusline+=%=   " Right align.

  " File format, encoding and type.  Ex: "(unix/utf-8/python)"
  " set statusline+=(
  " set statusline+=%{&ff}                        " Format (unix/DOS).
  " set statusline+=/
  " set statusline+=%{strlen(&fenc)?&fenc:&enc}   " Encoding (utf-8).
  " set statusline+=/
  " set statusline+=%{&ft}                        " Type (python).
  " set statusline+=)
  "
  " " Line and column position and counts.
  " #set statusline+=\ %l\/%L:%03c"
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
  " Easier to type
  noremap H ^
  noremap L $

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

    let NERDTreeHighlightCursorline=1
    :noremap ,n :NERDTreeToggle<CR>
  " }

  " Gist {
    " Copy to clipboard
    let g:gist_clip_command = 'pbcopy'
    " Detect type from filename
    let g:gist_detect_filetype = 1
    " Don't open in browser after gisting
    let g:gist_open_browser_after_post = 0
  " }

  " CtrlP {
    let g:ctrlp_map = '<c-t>'
    " Set working directory to nearest ancester that has a .git directory
    let g:ctrlp_working_path_mode = 2
    " Don't search in version control directories
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*
  " }
  
  " Fugitive {
    nnoremap <leader>gd :Gdiff<cr>
    nnoremap <leader>gs :Gstatus<cr>
    nnoremap <leader>gw :Gwrite<cr>
    nnoremap <leader>ga :Gadd<cr>
    nnoremap <leader>gb :Gblame<cr>
    nnoremap <leader>gco :Gcheckout<cr>
    nnoremap <leader>gc :Gcommit<cr>
    nnoremap <leader>gm :Gmove<cr>
    nnoremap <leader>gr :Gremove<cr>
    nnoremap <leader>gl :Shell git gl -18<cr>:wincmd \|<cr>
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

  " Rainbow {
    runtime plugin/RainbowParenthsis.vim 
  " }
" }
