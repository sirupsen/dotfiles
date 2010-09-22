" A lot stolen from 'The Ultimate .Vimrc File'
" http://spf13.com/post/ultimate-vim-config
"

" Setup Bundle Support {
  call pathogen#runtime_append_all_bundles()
" }

" Basics {
  set nocompatible " No vi compatility
  set background=dark " Assume a dark background
" }

" General {
  let mapleader="," " Mapleader

  syntax on " Enable syntax highlightation.
  colorscheme mustang " Default colorscheme
  filetype plugin indent on " Automatically change file types.

  set mouse=a " Enable mouse usage.
  set autochdir " Automatically always switch to the current files directory.
  scriptencoding utf-8 " Utf-8 encoding.
  set shortmess+=filmnrxo0tT " Abbrev. of messages
  set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
  set history=1000 " Keep (a lot) more history

  " No needs for backups, I have Git for that
  set noswapfile 
  set nobackup
" }

" Vim UI {
  set ruler " Enable cursor position
  set showcmd  " Show incomplete CMDS at the bottom

  hi cursorline guibg=#333333     " highlight bg color of current line
068
  " hi CursorColumn guibg=#333333   " highlight cursor
  
  set showmatch " Show matching of: () [] {}
  set matchpairs+=<:> " Match <> (HTML)

  " Set the font :)
  set gfn=Monaco\ 9

  set ignorecase " Case insensitive search
  set smartcase " Case sensitive when uppercase is present
  set incsearch " Search as you type
  set hlsearch " Highlight search matches

  set autoread " Auto read when file is changed

  set hidden " Hide buffers, rather than close them

  au FocusLost * :wa " Save when losing focus

  " GVim {
    if has("gui_running")
      set guioptions-=m " Remove menu bar
      set guioptions-=T " Remove toolbar with icons
      set guioptions-=r " Remove scrollbars (http://vimdoc.sourceforge.net/htmldoc/options.html#%27guioptions%27)
      set guioptions-=l
      set guioptions-=L

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
      autocmd VimEnter * NERDTree ~/Code

      " Default lines, columns as well as default position for gVim
      set lines=65
      set columns=115
      winpos 1295 30

      " 256 colorscheme
      colorscheme railscasts
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
" }

" Key Mapping {
  map <C-J> <C-W>j<C-W>_
  map <C-K> <C-W>k<C-W>_
  map <C-L> <C-W>l<C-W>_
  map <C-H> <C-W>h<C-W>_
  map <C-K> <C-W>k<C-W>_
  map <S-H> gT
  map <S-L> gt

  " Shift key fixes
  cmap W w
  cmap WQ wq
  cmap wQ wq
  cmap Q q

  " Quickly edit/reload the vimrc file
  nmap <silent> <leader>ev :e $MYVIMRC<CR>
  nmap <silent> <leader>sv :so $MYVIMRC<CR>

  " Key mappings
  :noremap ,d :bd<CR>
  cmap w!! w !sudo tee
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

  " SnipMate {
    " Author var
    let g:snips_author = 'Steve Francia <<a class="linkclass" href="mailto:steve.francia@gmail.com">steve.francia@gmail.com</a>>'

    " Shortcut for reloading snippets
    nnoremap ,smr <esc>:exec ReloadAllSnippets()<cr>
  " }
" }
