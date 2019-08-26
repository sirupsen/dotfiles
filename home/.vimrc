" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=1000  " Keep more history, default is 20
set mouse=v " Allow copy-pasting

call plug#begin('~/.config/nvim/plugged')

Plug 'junegunn/fzf', { 'do': 'yes \| ./install --all' }
Plug 'junegunn/goyo.vim'
Plug 'zxqfl/tabnine-vim'

" {{{
let g:ycm_add_preview_to_completeopt = 0
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_max_num_candidates = 10
" }}}

Plug 'junegunn/fzf.vim'
" {{{
" The nice thing about the immediate one below is that it'll start searching
" immediately. However, everything will buffer inside of FZF which is so much
" flower than providing an initial query.
" map <C-g> :execute 'Rg ' . input('Rg/', expand('<cword>'))<CR>
map <C-g> :Rg<CR>
map <leader>/ :execute 'Rg ' . input('Rg/')<CR>
map <Space>/ :execute 'Rg ' . input('Rg/', expand('<cword>'))<CR>
map <C-t> :FZF<CR>
map <C-j> :Buffers<CR>
map <C-t> :FZF<CR>
map <C-j> :Buffers<CR>

" Ctags
map <C-l> :Tags<CR>
map <Space><C-l> :call fzf#vim#tags(expand('<cword>'))<CR>
set tags=tags,.git/tags " Use commit hook tags, see ~/.git_template
map <leader>rl :silent exec '!bash -c "( cd $(git rev-parse --show-toplevel) && ~/.git_template/hooks/ctags )"'<CR>

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

" TODO: Do this automatically when ftype is Rust (or there's a Cargo.toml in root)
command! FZFCrate :FZF ~/.cargo/registry/src
command! SqlFormat :%!sqlformat --reindent --keywords upper --identifiers lower -

function! FzfGem(name)
  let path = system("bundle show " . a:name)
  let path = substitute(path, '\n', '', '')
  execute ":FZF " . path
endfunction
command! -nargs=* FZFGem call FzfGem(<f-args>)

" Hack to set the working directory in the new tab
au TabNewEntered * if exists("g:wd") | exe "tcd " . g:wd | let g:wd = 0 | endif 
function! Gem(name)
  let path = system("bundle show " . a:name)
  let path = substitute(path, '\n', '', '')
  let g:wd = path
  execute ":tabnew " . path
endfunction
command! -nargs=* Gem call Gem(<f-args>)

function! Gems()
  let path = system("ruby -e 'puts Gem.user_dir'")
  let path = substitute(path, '\n', '', '')
  execute ":FZF " . path
endfunction
command! -nargs=* Gems call Gems()

function! Crate(name)
  let path = system("bash -c \"cargo metadata --format-version 1 | rb 'from_json[:packages].find { |c| c[:name] =~ /" . a:name . "/ }[:targets][0][:src_path]'\"")
  let path = substitute(path, '\n', '', '')
  let dir_path = fnamemodify(path, ':p:h') . "/../"
  let g:wd = dir_path
  execute ":tabnew " . path
endfunction
command! -nargs=* Crate call Crate(<f-args>)

" command! CrateOpen `cargo metadata --format-version 1 | rb 'from_json["packages"].find { |c| c["name"] =~ /feed/ }["targets"][0]["src_path"]'`

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }
let $FZF_DEFAULT_OPTS = '--bind ctrl-a:toggle-all'
" }}}

Plug 'janko-m/vim-test'
" {{{
let test#strategy = "vimux"
let g:VimuxTmuxCommand = "/usr/local/bin/tmux"
map <leader>t :TestNearest<CR>
map <leader>T :TestFile<CR>
map <Space>t :TestLast<CR>
" }}}

Plug 'benmills/vimux'
" {{{
let g:VimuxOrientation = "h"
let g:VimuxHeight = "40"
" }}}

Plug 'airblade/vim-gitgutter'
" {{{
nmap [h <Plug>GitGutterPrevHunk
nmap ]h <Plug>GitGutterNextHunk
set updatetime=100
" }}}

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" {{{
map <leader>n :NERDTreeToggle<CR>
" }}}
Plug 'rhysd/devdocs.vim'
" {{{
nmap K <Plug>(devdocs-under-cursor)
" }}}
Plug 'w0rp/ale'
" {{{
let g:ale_rust_cargo_use_clippy = executable('cargo-clippy')
let g:ale_fixers = {'rust': ['rustfmt'], 'ruby': ['bundle exec rubocop -a']}
let g:ale_lint_delay = 1000
let g:ale_ruby_rubocop_executable = 'bundle'
let g:ale_rust_cargo_check_tests = 1
let g:ale_rust_cargo_check_examples = 1

let g:ale_set_highlights = 0 " signs are enough
let g:ale_cursor_detail = 0
let g:ale_close_preview_on_insert = 1

map <leader>f :ALEFix<CR>
map [a :ALEPrevious<CR>
map ]a :ALENext<CR>
" }}}
Plug 'thalesmello/webcomplete.vim'
Plug 'milkypostman/vim-togglelist'
Plug 'tpope/vim-endwise', { 'for': 'ruby' }
Plug 'tpope/vim-fugitive'
" {{{
map <leader>gs :Gstatus<CR>
map <leader>gc :Gcommit<CR>
" }}}
"
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-obsession'
Plug 'chriskempson/base16-vim'
Plug 'nickhutchinson/vim-systemtap'
Plug 'tpope/vim-liquid'
Plug 'plasticboy/vim-markdown'
" {{{
let g:vim_markdown_folding_disabled = 1
" }}}
Plug 'tpope/vim-rails', { 'for': 'ruby' }
Plug 'junegunn/vim-emoji'
" {{
command! -range EmojiReplace <line1>,<line2>s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g
" }}
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
" {{
let ruby_operators = 1
let ruby_space_errors = 1
let ruby_fold = 1
let ruby_no_expensive = 1
let ruby_spellcheck_strings = 1
" }}
Plug 'vim-scripts/VimClojure', { 'for': 'clojure' }
Plug 'kchmck/vim-coffee-script'
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': 'javascript' }
Plug 'derekwyatt/vim-scala', { 'for': 'scala' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'elixir-editors/vim-elixir', { 'for': 'elixir' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
" {{{
let g:rustfmt_autosave = 0
" }}}
Plug 'cespare/vim-toml', { 'for': 'toml' }
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
let base16colorspace=256
colorscheme base16-default-dark
" set background=dark " Set dark solarized theme
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

set tabstop=2 " Tabs are 2 spaces
set backspace=2 " Backspace deletes 2 spaces
set shiftwidth=2 " Even if there are tabs, preview as 2 spaces

set list " Highlight trailings, stolen from @teoljungberg
set listchars=tab:>-,trail:.,extends:>,precedes:<

set nohlsearch " Don't highlight search results

set diffopt=filler,vertical

if has('nvim')
  set inccommand=split " Neovim will preview search
end

imap jk <esc>
map <leader>d :bd<CR>
" Sane behavior on long lines
nmap k gk
nmap j gj
" Make Y behave like other capitals
nnoremap Y y$
nnoremap ]t :tabn<cr>
nnoremap [t :tabp<cr>
nmap L :set invnumber<CR>

command! Breakpoint :call VimuxRunCommand("b " . bufname("%") . ":" . line("."))

map <leader>c :let @*=expand("%:p")<CR>
map <Space>b :Breakpoint<CR>
command! Style :call VimuxRunCommand("dev style")<CR>

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

au BufNewFile,BufRead *.ejson set filetype=json
au BufNewFile,BufRead *.sxx set filetype=stp
autocmd BufNewFile,BufRead *.md,*.markdown set spell
autocmd FileType go,gitcommit,qf,gitset setlocal nolist " Go fmt will use tabs
set hidden
autocmd! BufWritePost $MYVIMRC source $MYVIMRC

function! s:statusline_expr()
  let mod = "%{&modified ? '[+] ' : !&modifiable ? '[x] ' : ''}"
  let ro  = "%{&readonly ? '[RO] ' : ''}"
  let ft  = "%{len(&filetype) ? '['.&filetype.'] ' : ''}"
  let fug = "%{exists('g:loaded_fugitive') ? fugitive#statusline() : ''}"
  let sep = ' %= '
  let pos = ' %-12(%l : %c%V%) '
  let pct = ' %P'

  return '[%n] %F %<'.mod.ro.ft.fug.sep.pos.'%*'.pct
endfunction
let &statusline = s:statusline_expr()

let g:go_def_mapping_enabled = 0 " don't override ctrl-T
let g:python2_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

function! MRIIndent()
  setlocal cindent
  setlocal noexpandtab
  setlocal shiftwidth=4
  setlocal softtabstop=4
  setlocal tabstop=8
  setlocal textwidth=80
  " Ensure function return types are not indented
  setlocal cinoptions=(0,t0
endfunction

autocmd BufNewFile,BufRead /Users/simon/src/github.com/ruby/ruby/**/*.c call MRIIndent()
