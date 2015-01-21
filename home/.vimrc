" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=1000  " Keep more history, default is 20
set rtp+=~/.vim/bundle/neobundle.vim
call neobundle#rc(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'teoljungberg/vim-grep'
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-unimpaired'
NeoBundle 'tpope/vim-dispatch'
NeoBundle 'tpope/vim-commentary'
NeoBundle 'wincent/Command-T'
NeoBundle 'derekwyatt/vim-scala'
NeoBundle 'fatih/vim-go'
NeoBundle 'kchmck/vim-coffee-script'
NeoBundle 'pangloss/vim-javascript'
NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'vim-scripts/VimClojure'
NeoBundle 'tpope/vim-liquid'
NeoBundle 'tpope/vim-markdown'
NeoBundle 'tpope/vim-rails'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'reedes/vim-colors-pencil'
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'tsaleh/vim-matchit'
NeoBundle 'nelstrom/vim-textobj-rubyblock'
NeoBundle 'gcmt/wildfire.vim'
NeoBundle 'nelstrom/vim-visual-star-search'
NeoBundle 'nickhutchinson/vim-systemtap'

filetype plugin indent on " Enable after Vundle loaded, #dunnolol

" Allow editing crontabs http://vim.wikia.com/wiki/Editing_crontab
set backupskip=/tmp/*,/private/tmp/* "
set undodir=~/.vim/undo
set noswapfile
set nobackup

syntax enable
colorscheme solarized
set background=dark " Set dark solarized theme
set t_Co=256  " 2000s plz
set textwidth=80  " Switch line at 80 characters
set scrolloff=5   " Keep some distance to the bottom"
set showmatch     " Show matching of: () [] {}
set ignorecase    " Required for smartcase to work
set smartcase     " Case sensitive when uppercase is present
set incsearch     " Search as you type
set smartindent   " Be smart about indentation
set expandtab     " Tabs are spaces
set smarttab
set shell=$SHELL\ -l  " load shell for ruby version etc.

set tabstop=2 " Tabs are 2 spaces
set backspace=2 " Backspace deletes 2 spaces
set shiftwidth=2 " Even if there are tabs, preview as 2 spaces

set list " Highlight trailings, stolen from @teoljungberg
set listchars=tab:>-,trail:.,extends:>,precedes:<

set tags=.git/tags " Use commit hook tags, see ~/.git_template

map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l
map <C-H> <C-W>h
imap jk <esc>
map <leader>d :bd<CR>

" Sane behavior on long lines
nmap k gk
nmap j gj
noremap H ^
noremap L $

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

" Sane default tab-key, replaces Supertab.
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
imap <tab>   <c-r>=InsertTabWrapper()<cr>
imap <s-tab> <c-n>

au BufNewFile,BufRead *.ejson set filetype=json

autocmd BufNewFile,BufRead *.md,*.markdown set spell
autocmd BufNewFile,BufRead *_test.rb compiler rubyunit
autocmd BufNewFile,BufRead *_test.rb set makeprg=bundle\ exec\ testrb\ %
map <C-E> :Make<CR>

" autocmd FileType go compiler go
" autocmd BufWrite *.go :Fmt
" autocmd BufNewFile,BufRead *_test.go set makeprg=go\ test
autocmd FileType go,gitcommit,qf,gitset setlocal nolist " Go fmt will use tabs

map <leader>n :NERDTreeToggle<CR>

map <C-t> :CommandT<CR>
map <C-g> :CommandTTag<CR>
let g:CommandTAcceptSelectionSplitMap='<C-x>'
let g:CommandTMaxHeight=20

set wildignore+=.git/**,public/assets/**,vendor/**,log/**,tmp/**,Cellar/**,app/assets/images/**,_site/**,home/.vim/bundle/**,pkg/**,**/.gitkeep,**/.DS_Store,**/*.netrw*,node_modules/*

fun! StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun
" autocmd FileType c,bash,cpp,go,scala,markdown,clojure,javascript,ruby,python autocmd BufWritePre <buffer> :call StripTrailingWhitespaces()

let g:wildfire_objects = {
      \ "*" :    ["i'", 'i"', 'i)', 'i]', 'i}', "ip"],
      \ "ruby" : ["i'", 'i"', 'i)', "ir", "ar"],
      \ "markdown" : ["i'", 'i"', "is", "ip"]
\ }

match Error /\%81v.\+/ " Highilght columns after the 80th

let g:surround_{char2nr('%')} = "<% \r %>"
let g:surround_{char2nr('=')} = "<%= \r %>"
let g:surround_{char2nr('#')} = "#{\r}"
