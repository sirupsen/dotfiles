" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=1000  " Keep more history, default is 20
set mouse=v " Allow copy-pasting

call plug#begin('~/.config/nvim/plugged')

Plug 'junegunn/fzf', { 'do': 'yes \| ./install --all' }
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --rust-completer --go-completer' }
Plug 'junegunn/fzf.vim'
Plug 'janko-m/vim-test'
Plug 'benmills/vimux'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'rhysd/devdocs.vim'
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins', 'for': 'rust' }
Plug 'thalesmello/webcomplete.vim'
" Plug 'vim-syntastic/syntastic'
Plug 'milkypostman/vim-togglelist'

Plug 'tpope/vim-endwise', { 'for': 'ruby' }
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-obsession'

Plug 'altercation/vim-colors-solarized'

Plug 'nickhutchinson/vim-systemtap'
Plug 'tpope/vim-liquid'
Plug 'plasticboy/vim-markdown'
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
Plug 'vim-scripts/VimClojure', { 'for': 'clojure' }
Plug 'kchmck/vim-coffee-script'
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': 'javascript' }
Plug 'derekwyatt/vim-scala', { 'for': 'scala' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'elixir-editors/vim-elixir', { 'for': 'elixir' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
Plug 'uarun/vim-protobuf'
Plug 'leafgarland/typescript-vim'
Plug 'jparise/vim-graphql'
Plug 'racer-rust/vim-racer'

call plug#end()

filetype plugin indent on " Enable after Vundle loaded, #dunnolol

" Allow editing crontabs http://vim.wikia.com/wiki/Editing_crontab
set backupskip=/tmp/*,/private/tmp/* "
set undodir=~/.vim/undo
set noswapfile
set nobackup
set wildignore+=.git/**,public/assets/**,log/**,tmp/**,Cellar/**,app/assets/images/**,_site/**,home/.vim/bundle/**,pkg/**,**/.gitkeep,**/.DS_Store,**/*.netrw*,node_modules/*

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
" set shell=$SHELL\ -l  " load shell for ruby version etc.

set tabstop=2 " Tabs are 2 spaces
set backspace=2 " Backspace deletes 2 spaces
set shiftwidth=2 " Even if there are tabs, preview as 2 spaces

set list " Highlight trailings, stolen from @teoljungberg
set listchars=tab:>-,trail:.,extends:>,precedes:<

set nohlsearch " Don't highlight search results

set tags=tags,.git/tags " Use commit hook tags, see ~/.git_template

set diffopt=filler,vertical
set inccommand=split " Neovim will preview search

imap jk <esc>
map <leader>d :bd<CR>

" Sane behavior on long lines
nmap k gk
nmap j gj

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
au BufNewFile,BufRead *.sxx set filetype=stp

autocmd BufNewFile,BufRead *.md,*.markdown set spell

autocmd FileType go,gitcommit,qf,gitset setlocal nolist " Go fmt will use tabs
" autocmd! BufWritePost * Neomake

map <leader>n :NERDTreeToggle<CR>

nmap L :set invnumber<CR>

let test#strategy = "vimux"
nmap <silent> <leader>t :TestNearest<CR>
nmap <silent> <leader>T :TestFile<CR>
nmap <silent> <leader>l :TestLast<CR>

nmap <silent> <leader>a :call VimuxRunCommand("b " . bufname("%") . ":" . line("."))<CR>
nmap <silent> <Leader>f :call VimuxRunCommand("dev test " . bufname("%") . " -n /WIP/")<CR>
" nmap <silent> <Leader>r :call VimuxRunCommand("rubocop " . bufname("%"))<CR>
nmap <silent> <Leader>R :call VimuxRunCommand("dev style")<CR>

let g:jsx_ext_required = 0

" Git gutter
set updatetime=100

" rust
set hidden

" Use Ctags for now, maybe return to this later
" au FileType rust nmap gd <Plug>(rust-def)
" au FileType rust nmap <leader>gd <Plug>(rust-doc)
" autocmd FileType rust          nnoremap <buffer> <C-0> :YcmCompleter GoTo<CR>
let g:VimuxTmuxCommand = "/usr/local/bin/tmux"

nmap K :YcmCompleter GetDoc<CR>
nmap <leader>K <Plug>(devdocs-under-cursor)
let g:go_def_mapping_enabled = 0 " don't override ctrl-T

let g:VimuxOrientation = "h"
let g:VimuxHeight = "40"

let g:python2_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

" let g:syntastic_always_populate_loc_list = 1
" let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 0
" let g:syntastic_check_on_wq = 0
" let g:syntastic_rust_checkers = ['cargo']


" command! -bang -nargs=* GGrep
"   \ call fzf#vim#grep(
"   \   'git grep --line-number -P "' . <q-args> . '"', 0,
"   \   { 'dir': systemlist('git rev-parse --show-toplevel')[0] }, <bang>0)

" map <C-g> :GGrep<CR>

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

map <C-g> :Rg<CR>
map <C-t> :FZF<CR>
map <C-h> :Buffers<CR>
map <C-l> :call fzf#vim#tags(expand('<cword>'))<CR>
map <leader>cl :silent exec '!bash -c "( cd $(git rev-parse --show-toplevel) && .git/hooks/ctags )"'<CR>

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

let $FZF_DEFAULT_OPTS = '--bind ctrl-a:toggle-all'

let g:vim_markdown_folding_disabled = 1
