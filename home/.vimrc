" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=1000  " Keep more history, default is 20
set mouse=v " Allow copy-pasting

set statusline=
set statusline+=%f:%l:%c\ %m
set statusline+=%{tagbar#currenttag('\ [%s]\ ','','')}
set statusline+=%=
set statusline+=%{FugitiveStatusline()}

call plug#begin('~/.config/nvim/plugged')

Plug 'hari-rangarajan/CCTree'
" {{
function LoadCscopeDB()
  if filereadable('cscope.out')
    cscope add cscope.out
  endif
endfunction
au VimEnter * call LoadCscopeDB()
let g:CCTreeSplitProg = 'gsplit'
set cscopequickfix=s-,c-,d-,i-,t-,e-,a-

" }}
Plug 'majutsushi/tagbar'
" {{{
nmap \l :TagbarToggle<CR>
map <C-W>[ :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
let g:tagbar_compact = 1
let g:tagbar_indent = 1
" }}}
function! LookupDocs()
  if &filetype ==# 'c' || &filetype ==# 'cpp'
    call system("open 'https://www.google.com/search?q=" . expand('<cword>') . "&sitesearch=man7.org%2Flinux%2Fman-pages'")
  elseif &filetype ==# 'markdown'
    call system("chrome-cli open https://google.com/search?q=define%20" . expand('<cword>'))
  elseif &filetype ==# 'rust'
    let crate_link = "file:///" . getcwd() . "/target/doc/settings.html?search=" . expand('<cword>')
    let stdlib_link = 'https://doc.rust-lang.org/std/?search=' . expand('<cword>')

    let stdlib_tab = trim(system("chrome-cli list links | grep 'doc.rust-lang.org' | grep -oE '[0-9]+'"))
    let crate_tab = trim(system("chrome-cli list links | grep '" . getcwd() . "' | grep -oE '[0-9]+'"))
    let active_tab = trim(system("chrome-cli info | grep -Eo '\d+' | head -n1"))

    if stdlib_tab
      call system("chrome-cli open " . stdlib_link . " -t " . stdlib_tab)
    else
      call system("chrome-cli open " . stdlib_link)
    end

    if crate_tab
      call system("chrome-cli open " . crate_link . " -t " . crate_tab)
      if active_tab != stdlib_tab && active_tab != crate_tab
        call system("chrome-cli activate -t " . crate_tab)
      end
    else
      call VimuxRunCommand("cargo doc &")
      call system("chrome-cli open " . crate_link)
    end
  elseif &filetype ==# 'ruby'
    " could prob make this use ri(1)
    call system("chrome-cli open https://ruby-doc.com/search.html?q=" . expand('<cword>'))
  else
    call system("chrome-cli open https://google.com/search?q=" . &filetype . "%20" . expand('<cword>'))
  endif
endfunction

nmap K :call LookupDocs()<cr>
" }}}
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }
" {{{
let g:deoplete#enable_at_startup = 1

inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ deoplete#manual_complete()

function! s:check_back_space() abort "{{{
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}
" }}}
Plug 'junegunn/fzf', { 'do': 'yes \| ./install --all' }
Plug 'junegunn/fzf.vim'
" {{{
let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }

function! FzfSpellSink(word)
  exe 'normal! "_ciw'.a:word
endfunction

function! FzfSpell()
  let suggestions = spellsuggest(expand("<cword>"))
  return fzf#run(fzf#wrap({'source': suggestions, 'sink': function("FzfSpellSink"), 'window': { 'width': 0.6, 'height': 0.3 }}))
endfunction

nnoremap z= :call FzfSpell()<CR>

let g:fzf_tags_command = 'bash -c "build-ctags"'

let g:fzf_history_dir = '~/.fzf-history'
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let options = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  if a:fullscreen
    let options = fzf#vim#with_preview(options)
  endif
  call fzf#vim#grep(initial_command, 1, options, a:fullscreen)
endfunction

" command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
" Completely use RG, don't use fzf's fuzzy-matching
map <C-g> :RG<CR>
map <Space>/ :execute 'Rg ' . expand('<cword>')<CR>
map <leader>/ :execute 'Rg ' . input('Rg/')<CR>

" map <C-g> :Rg<CR>
" map <leader>/ :execute 'RG ' . input('Rg/')<CR>
" map <Space>/ :execute 'RG ' . input('Rg/', expand('<cword>'))<CR>

command! -bang -nargs=? -complete=dir Files
    \ call fzf#vim#files(<q-args>, {'options': ['--tiebreak=begin']}, <bang>0)
map <C-t> :Files<CR>

map <C-j> :Buffers<CR>
map <A-c> :Commands<CR>

map <C-l> :Tags<CR>
map <Space>l :call fzf#vim#tags(expand('<cword>'))<CR>
map <A-l> :BTags<CR>
map <Space><A-l> :call fzf#vim#buffer_tags(expand('<cword>'))<CR>

function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

command! SqlFormat :%!sqlformat --reindent --keywords upper --identifiers lower -

function! FzfGem(name)
  let path = system("bundle info ".a:name." | rg -oP '(?<=Path: )(.+)$'")
  let path = substitute(path, '\n', '', '')
  execute ":FZF " . path
endfunction
command! -nargs=* FZFGem call FzfGem(<f-args>)

function! Gem(name)
  let path = system("bundle info ".a:name." | rg -oP '(?<=Path: )(.+)$'")
  let path = substitute(path, '\n', '', '')
  silent execute ":!tmux new-window -n 'gem:" . a:name . "' bash -l -c 'cd " . path . " && vim -c \':FZF\''"
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
  \ 'ctrl-o': ':r !basename',
  \ 'alt-o':  ':r !echo',
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
let g:VimuxUseNearest = 1

function! RepeatLastTmuxCommand()
  call VimuxRunCommand('Up')
endfunction
map <C-e> :call RepeatLastTmuxCommand()<CR>

function! RunSomethingInTmux()
  if &filetype ==# 'markdown'
    call VimuxRunCommand(expand('%'))
  end
endfunction
map <A-e> :call RunSomethingInTmux()<CR>

" this is useful for debuggers etc
command! CurrentBuffer :call VimuxSendText(bufname("%") . ":" . line("."))
map <Space>b :CurrentBuffer<CR>
" }}}

Plug 'airblade/vim-gitgutter'
" {{{
nmap [h <Plug>(GitGutterPrevHunk)
nmap ]h <Plug>(GitGutterNextHunk)
set updatetime=100
" }}}

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" {{{
map \t :NERDTreeToggle<CR>
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
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-fugitive'
" {{{
map <leader>gs :Gstatus<CR>
map <leader>gc :Gcommit<CR>
" }}}
Plug 'AndrewRadev/splitjoin.vim'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-obsession'
Plug 'terryma/vim-multiple-cursors'
Plug 'chriskempson/base16-vim'
Plug 'nickhutchinson/vim-systemtap'
Plug 'plasticboy/vim-markdown'
" {{
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 0

" https://agilesysadmin.net/how-to-manage-long-lines-in-vim/
autocmd FileType markdown setlocal spell
autocmd FileType markdown setlocal linebreak " wrap on words, not characters

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
" {{
let g:fzf_tags_command = 'ctags -R'
let g:go_def_mapping_enabled = 0
" }}
Plug 'elixir-editors/vim-elixir', { 'for': 'elixir' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
" {{{
let g:rustfmt_autosave = 0
let g:rust_recommended_style = 1
" }}}
Plug 'cespare/vim-toml', { 'for': 'toml' }
Plug 'uarun/vim-protobuf'
Plug 'leafgarland/typescript-vim'
Plug 'jparise/vim-graphql'
Plug 'racer-rust/vim-racer'
Plug 'Shirk/vim-gas'

call plug#end()

" Have to be after deoplete for some reason
call deoplete#custom#option({
\ 'smart_case': v:true,
\ 'prev_completion_mode': "prev_completion_mode",
\ 'sources': {
\   '_': ['tabnine'],
\ }
\ })

autocmd FileType markdown call deoplete#custom#buffer_option('ignore_sources', ['around', 'buffer', 'tabnine'])

" Don't completee in strings and comments
call deoplete#custom#source('_',
            \ 'disabled_syntaxes', ['Comment', 'String'])

call deoplete#custom#var('tabnine', {
\ 'line_limit': 500,
\ 'max_num_results': 20,
\ })

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

" set list " Highlight trailings, stolen from @teoljungberg
" set listchars=tab:>-,trail:.,extends:>,precedes:<
" set listchars=trail:.,extends:>,precedes:<
autocmd FileType go,gitcommit,qf,gitset,gas,asm setlocal nolist

set nohlsearch " Don't highlight search results
set diffopt=filler,vertical
if has('nvim')
  set inccommand=split " Neovim will preview search
end

imap jk <esc>
map <leader>d :bd<CR>
nnoremap Y y$ " Make Y behave like other capitals
nmap L :set invnumber<CR>
" https://medium.com/@vinodkri/zooming-vim-window-splits-like-a-pro-d7a9317d40
" map <c-w>z <c-w>_ \| <c-w>\|
function! s:zoom()
  if winnr('$') > 1
    tab split
  elseif len(filter(map(range(tabpagenr('$')), 'tabpagebuflist(v:val + 1)'),
                  \ 'index(v:val, '.bufnr('').') >= 0')) > 1
    tabclose
  endif
endfunction
nnoremap <silent> <c-w>z :call <sid>zoom()<cr>

" Yank the file name without extension
map cf :let @" = expand("%:r")<CR>
" Yank the full current file pathk
map cF :let @* = expand("%:p")<CR>

" Rename current file, thanks Gary Bernhardt via Ben Orenstein
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name !=# old_name
    exec ':saveas ' . fnameescape(new_name)
    exec ':silent !rm ' . fnameescape(old_name)
    redraw!
  endif
endfunction
nnoremap <leader>r :call RenameFile()<cr>

au BufNewFile,BufRead *.ejson set filetype=json
au BufNewFile,BufRead *.s set filetype=gas
set nospell
" allow spaces in file-names, which makes gf more useful
set isfname+=32
set hidden
autocmd! BufWritePost $MYVIMRC source $MYVIMRC
map <space>v :source $MYVIMRC<CR>
map <leader>v :sp $MYVIMRC<CR>

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

autocmd BufNewFile,BufRead ~/src/github.com/ruby/ruby/**/*.c call MRIIndent()

" https://stackoverflow.com/questions/4946421/vim-moving-with-hjkl-in-long-lines-screen-lines
function! ScreenMovement(movement)
   if &wrap
      return "g" . a:movement
   else
      return a:movement
   endif
endfunction
onoremap <silent> <expr> j ScreenMovement("j")
onoremap <silent> <expr> k ScreenMovement("k")
onoremap <silent> <expr> 0 ScreenMovement("0")
onoremap <silent> <expr> ^ ScreenMovement("^")
onoremap <silent> <expr> $ ScreenMovement("$")
nnoremap <silent> <expr> j ScreenMovement("j")
nnoremap <silent> <expr> k ScreenMovement("k")
nnoremap <silent> <expr> 0 ScreenMovement("0")
nnoremap <silent> <expr> ^ ScreenMovement("^")
nnoremap <silent> <expr> $ ScreenMovement("$")

" set autochdir
set tags=./tags,tags;
function! BuildCtags()
  silent execute ":!bash -lc ctags-build"
endfunction
command! -nargs=* BuildCtags call BuildCtags()

function! BuildCscope()
  silent execute ":!bash -lc cscope-build"
endfunction
command! -nargs=* BuildCscope call BuildCscope()

function! SNote(...)
  let path = strftime("%Y%m%d%H%M")." ".trim(join(a:000)).".md"
  execute ":sp " . fnameescape(path)
endfunction
command! -nargs=* SNote call SNote(<f-args>)

function! Note(...)
  let path = strftime("%Y%m%d%H%M")." ".trim(join(a:000)).".md"
  execute ":e " . fnameescape(path)
endfunction
command! -nargs=* Note call Note(<f-args>)

function! ZettelkastenSetup()
  syn region mkdFootnotes matchgroup=mkdDelimiter start="\[\["    end="\]\]"

  inoremap <expr> <plug>(fzf-complete-path-custom) fzf#vim#complete#path("rg --files -t md \| sed 's/^/[[/g' \| sed 's/$/]]/'")
  imap [[ <plug>(fzf-complete-path-custom)

  inoremap <expr> <plug>(fzf-complete-tag) fzf#vim#complete#path("rg -o \"#[a-zA-Z0-9-_]\{3,\}\" -t md -N --no-filename \| sort \| uniq')
  imap # <plug>(fzf-complete-tag) <esc>

  " setlocal formatoptions+=a
  imap -- —
endfunction
autocmd BufNew,BufRead ~/Documents/Zettelkasten/*.md call ZettelkastenSetup()
