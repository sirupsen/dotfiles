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
" }

" Vim UI {
  syntax on " Enable syntax highlightation.¨

  color mustang " Default colorscheme

  set t_Co=256 " Terminal colors

  set ruler " Enable cursor position
  set showcmd  " Show incomplete CMDS at the bottom
  
  set showmatch " Show matching of: () [] {}
  set matchpairs+=<:> " Match <> (HTML)

  " Searching {
    set ignorecase " Case insensitive search
    set smartcase " Case sensitive when uppercase is present
    set incsearch " Search as you type
    "set hlsearch " Highlight search matches
  " }

  set autoread " Auto read when file is changed

  set hidden " Hide buffers, rather than close them

  set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P

  " GVim {
    if has("gui_running")
      color vividchalk " GUI Colorscheme
      set guifont=Monaco\ 9 " Set the font:

      " GVIm options {
        set guioptions-=m " Remove menu bar
        set guioptions-=T " Remove toolbar with icons
        set guioptions-=r " Remove scrollbars (http://vimdoc.sourceforge.net/htmldoc/options.html#%27guioptions%27)
        set guioptions-=l
        set guioptions-=L
      " }

      " Title {
        if has('title')
          set titlestring=
          set titlestring+=%f\                                              " file name
          set titlestring+=%h%m%r%w                                         " flags
          set titlestring+=\ -\ %{v:progname}                               " program name
          set titlestring+=\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}  " working directory
        endif
      " }

      " Autoload NERDTree in Gui
      autocmd VimEnter * NERDTree ~/Dropbox/code

      " Window {
        set lines=65
        set columns=115
        winpos 1270 0
      " }
    endif
  " }

  " MVIM {
    if has("gui_macvim")
      macmenu &File.New\ Tab key=<nop>
      map <D-t> :CommandT<CR>
      set guifont=Monaco:h10
    endif
  " }
" }

" Formatting {
  " Be smart, and awesome, about indentation
  set autoindent " Indent at the same level as previous line
  set smartindent
  set smarttab
  set expandtab " Tabs are spaces

  "set sw=2
  "set sts=2
  set tabstop=2 " Tabs are 2 spaces
  set backspace=2 " Backspace back 2 spaces
  set shiftwidth=2 " Even if there are tabs, preview as 2 spaces

  " Man pager
  let $PAGER=''
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

  " Shift key fixes
  cmap W w
  cmap WQ wq
  cmap wQ wq
  cmap Q q

  " Quickly edit/reload the vimrc file
  omap <silent> <leader>ev :e $MYVIMRC<CR>
  nmap <silent> <leader>sv :so $MYVIMRC<CR>

  " Key mappings
  :noremap ,d :bd<CR>
  cmap w!! w !sudo tee %
  map ,c :cd %:p:h<CR>
" }


" Plugins {
  " NerdTree {
    let NERDTreeChDirMode = 1
    let NERDTreeWinSize=20

    :noremap ,n :NERDTreeToggle<CR>
  " }

  " Gist {
    let g:gist_detect_filetype = 1
    let g:gist_open_browser_after_post = 1
  " }

  " Delimitmate {
    au FileType * let b:delimitMate_autoclose = 1
  " }

  " SnipMate {
    " Author var
    let g:snips_author = 'Simon Hørup Eskildsen <<a class="linkclass" href="mailto:sirup@sirupsen.com">sirup@sirupsen.com</a>>'

    " Shortcut for reloading snippets
    nnoremap ,smr <esc>:exec ReloadAllSnippets()<cr>
  " }

  " Jekyll {
    let g:jekyll_path = "~/Code/projects/sirupsen.com"
    let g:jekyll_post_suffix = "md"
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

  " Outliner {
    " defaults
    let otl_install_menu=1
    let no_otl_maps=0
    let no_otl_insert_maps=0

    " overrides:
    let otl_bold_headers=0
    let otl_use_thlnk=0

    " au BufWinLeave *.otl mkview
    " au BufWinEnter *.otl silent loadview
    let maplocalleader = ","
  " }

  " Ri {
  "source ~/.vim/bundle/ri/ftplugin/ri.vim
  " }
  
  " Command-T {
    nmap <Leader>f :CommandTFlush<CR>
    nmap <Leader>t :CommandT<CR>
  " }

  " Rainbow {
    runtime plugin/RainbowParenthsis.vim 
  " }
