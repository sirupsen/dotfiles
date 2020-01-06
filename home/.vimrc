" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=1000  " Keep more history, default is 20
set mouse=v " Allow copy-pasting

call plug#begin('~/.config/nvim/plugged')

Plug 'junegunn/fzf', { 'do': 'yes \| ./install --all' }
" Plug 'junegunn/goyo.vim'
" Plug 'zxqfl/tabnine-vim', { 'for': ['rust', 'vim', 'ruby', 'html', 'go', 'python'] }
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" {{{
set cmdheight=2
set shortmess+=c
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <c-space> coc#refresh()
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Create mappings for function text object, requires document symbols feature of languageserver.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for select selections ranges, needs server support, like: coc-tsserver, coc-python
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
" let g:ycm_add_preview_to_completeopt = 0
" let g:ycm_autoclose_preview_window_after_completion = 1
" let g:ycm_autoclose_preview_window_after_insertion = 1
" let g:ycm_max_num_candidates = 10
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
map <C-l> :Tags<CR>
map <Space>l :call fzf#vim#tags(expand('<cword>'))<CR>
set tags=tags,.git/tags " Use commit hook tags, see ~/.git_template
map <leader>rl :silent exec '!bash -c "( cd $(git rev-parse --show-toplevel) && ~/.git_template/hooks/ctags )"'<CR>

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

command! SqlFormat :%!sqlformat --reindent --keywords upper --identifiers lower -

function! FzfGem(name)
  let path = system("bundle show " . a:name)
  let path = substitute(path, '\n', '', '')
  execute ":FZF " . path
endfunction
command! -nargs=* FZFGem call FzfGem(<f-args>)

function! Gem(name)
  let path = system("bundle show " . a:name)
  let path = substitute(path, '\n', '', '')
  silent execute ":!tmux new-window -n 'gem:" . a:name . "' bash -c 'cd " . path . " && vim -c \':FZF\''"
endfunction
command! -nargs=* Gem call Gem(<f-args>)

function! Crate(name)
  let path = system("bash -c \"cargo metadata --format-version 1 | rb 'from_json[:packages].find { |c| c[:name] =~ /" . a:name . "/ }[:targets][0][:src_path]'\"")
  let path = substitute(path, '\n', '', '')
  let dir_path = fnamemodify(path, ':p:h') . "/../"
  silent execute ":!tmux new-window -n 'crate:" . a:name . "' bash -c 'cd " . dir_path . " && vim -c \':FZF\''"
endfunction
command! -nargs=* Crate call Crate(<f-args>)

function! FzfCrate(name)
  let path = system("bash -c \"cargo metadata --format-version 1 | rb 'from_json[:packages].find { |c| c[:name] =~ /" . a:name . "/ }[:targets][0][:src_path]'\"")
  let path = substitute(path, '\n', '', '')
  let dir_path = fnamemodify(path, ':p:h') . "/../"
  execute ":FZF " . dir_path
endfunction
command! -nargs=* FZFCrate call FzfCrate(<f-args>)

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
map <leader>t :TestNearest<CR>
map <leader>T :TestFile<CR>
map <Space>t :TestLast<CR>
" }}}

Plug 'benmills/vimux'
" {{{
let g:VimuxTmuxCommand = "/usr/local/bin/tmux"
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
" nmap K <Plug>(devdocs-under-cursor)
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
command! Style :call VimuxRunCommand("dev style")<CR>
map [a :ALEPrevious<CR>
map ]a :ALENext<CR>
" }}}
Plug 'milkypostman/vim-togglelist'
Plug 'tpope/vim-endwise', { 'for': 'ruby' }
Plug 'tpope/vim-fugitive'
" {{{
map <leader>gs :Gstatus<CR>
map <leader>gc :Gcommit<CR>
" }}}
Plug 'AndrewRadev/splitjoin.vim'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-obsession'
Plug 'terryma/vim-multiple-cursors'
Plug 'chriskempson/base16-vim'
Plug 'nickhutchinson/vim-systemtap'
Plug 'tpope/vim-liquid'
Plug 'tpope/vim-markdown'
" {{{
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_auto_insert_bullets = 1

autocmd FileType markdown setlocal spell
augroup my_spelling_colors
  " Underline, don't do intrusive red things.
  autocmd!
  " autocmd ColorScheme * hi clear SpellBad
  autocmd ColorScheme * hi SpellBad cterm=underline ctermfg=NONE ctermbg=NONE term=Reverse
  autocmd ColorScheme * hi SpellCap cterm=underline ctermfg=NONE ctermbg=NONE term=Reverse
  autocmd ColorScheme * hi SpellLocal cterm=underline ctermfg=NONE ctermbg=NONE term=Reverse
  autocmd ColorScheme * hi SpellRare cterm=underline ctermfg=NONE ctermbg=NONE term=Reverse
augroup END
set spell spelllang=en_ca
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
let ruby_spellcheck_strings = 0
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
Plug 'Shirk/vim-gas'

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
set listchars=trail:.,extends:>,precedes:<
autocmd FileType go,gitcommit,qf,gitset,gas,asm setlocal nolist

set nohlsearch " Don't highlight search results
set diffopt=filler,vertical
if has('nvim')
  set inccommand=split " Neovim will preview search
end

imap jk <esc>
map <leader>d :bd<CR>
" nmap k gk " Sane behavior on long lines
" nmap j gj
nnoremap Y y$ " Make Y behave like other capitals
nmap L :set invnumber<CR>

" Yank the file name without extension
map cf :let @" = expand("%:r")<CR>
" Yank the full current file pathk
map cF :let @* = expand("%:p")<CR>

command! Breakpoint :call VimuxRunCommand("b " . bufname("%") . ":" . line("."))
map <Space>b :Breakpoint<CR>

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
au BufNewFile,BufRead *.s set filetype=gas
set nospell

set hidden
autocmd! BufWritePost $MYVIMRC source $MYVIMRC

let g:go_def_mapping_enabled = 0 " don't override ctrl-T
" let g:python2_host_prog = '/usr/local/bin/python'
" let g:python3_host_prog = '/usr/local/bin/python3'

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

autocmd BufNewFile,BufRead /Users/simoneskildsen/src/github.com/ruby/ruby/**/*.c call MRIIndent()
