" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=1000  " Keep more history, default is 20
set mouse=v " Allow copy-pasting
set mmp=5000 " Some files need more memory for syntax highlight

" <cword> then includes - as part of the word
set iskeyword+=-

set termguicolors
set statusline=
set statusline+=%f:%l:%c\ %m
" set statusline+=%{tagbar#currenttag('\ [%s]\ ','','')}
set statusline+=%=
set statusline+=%{FugitiveStatusline()}
let g:asyncrun_status = "stopped"
augroup QuickfixStatus
	au! BufWinEnter quickfix setlocal 
		\ statusline+=%t\ [%{g:asyncrun_status}]\ %{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l,%c%V%)\ %P
augroup END

let g:browser_new_tab = "chrome-cli open "

call plug#begin('~/.config/nvim/plugged')

Plug 'majutsushi/tagbar'
" {{{
nmap \l :TagbarToggle<CR>
map <C-W>[ :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
let g:tagbar_compact = 1
let g:tagbar_indent = 1
" }}}
" Plug 'github/copilot.vim'
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'bouk/deoplete-markdown-links'
" Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }
" Plug 'deoplete-plugins/deoplete-lsp'
Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/vim-vsnip'
Plug 'rafamadriz/friendly-snippets'
Plug 'onsails/lspkind-nvim'

Plug 'nvim-lua/plenary.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'folke/lsp-colors.nvim'
Plug 'williamboman/nvim-lsp-installer'
" Plug 'glepnir/lspsaga.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/trouble.nvim'
" {{{
" let g:deoplete#enable_at_startup = 1
" inoremap <silent><expr> <TAB>
"   \ pumvisible() ? "\<C-n>" :
"   \ <SID>check_back_space() ? "\<TAB>" :
"   \ deoplete#manual_complete()

function! s:check_back_space() abort "{{{
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}
" }}}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'chengzeyi/fzf-preview.vim' " For tag previews
Plug 'ibhagwan/fzf-lua'
Plug 'vijaymarupudi/nvim-fzf'
Plug 'kyazdani42/nvim-web-devicons'
" {{{

if exists('$TMUX')
  let g:fzf_layout = { 'tmux': '-p90%,60%' }
  let g:fzf_preview_window = 'right:50%'
else
  let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
endif
let g:fzf_tags_command = 'bash -c "build-ctags"'

function! FzfSpellSink(word)
  exe 'normal! "_ciw'.a:word
endfunction

function! FzfSpell()
  let suggestions = spellsuggest(expand("<cword>"))
  return fzf#run(fzf#wrap({'source': suggestions, 'sink': function("FzfSpellSink"), 'window': { 'width': 0.6, 'height': 0.3 }}))
endfunction
nnoremap z= :call FzfSpell()<CR>

let g:fzf_history_dir = '~/.fzf-history'
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --hidden --line-number --no-heading --color=always --smart-case %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let options = {'options': ['--phony', '--keep-right', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  if a:fullscreen
    let options = fzf#vim#with_preview(options)
  endif
  call fzf#vim#grep(initial_command, 1, options, a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
map <C-g> :RG<CR> " Completely use RG, don't use fzf's fuzzy-matching
map <Space>/ :execute 'Rg ' . expand('<cword>')<CR>
map <A-/> :BLines<CR>
map <leader>/ :execute 'Rg ' . input('Rg/')<CR>

" Redefine so for long paths in e.g. Java we still get the filename.
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': '--keep-right'}), <bang>0)
map <C-t> :Files<CR>

map <C-j> :Buffers<CR>
" Git Status
map <A-j> :GFiles?<CR>
map <A-c> :Commands<CR>
map <C-l> :FZFTags<CR>
map <A-l> :FZFBTags<CR>
map <Space>l :execute 'FZFTags ' . expand('<cword>')<CR>
map <Space><A-l> :execute 'FZFBTags ' . expand('<cword>')<CR>

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
  silent execute ":!tmux new-window -n 'gem:" . a:name . "' bash -l -c 'cd " . path . " && /opt/homebrew/bin/nvim -c \':FZF\''"
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

func! s:import_path(lines)
  exec ':r !path-to-import ' . a:lines[0]
endfunc

function! s:copy_results(lines)
  let joined_lines = join(a:lines, "\n")
  if len(a:lines) > 1
    let joined_lines .= "\n"
  endif
  let @+ = joined_lines
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-o': ':r !echo',
  \ 'ctrl-s': ':silent !git add %',
  \ 'ctrl-r':  function('s:import_path'),
  \ 'ctrl-y':  function('s:copy_results'),
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
let g:VimuxTmuxCommand = "/opt/homebrew/bin/tmux"
let g:VimuxOrientation = "h"
let g:VimuxHeight = "40"
let g:VimuxUseNearest = 1

function! RepeatLastTmuxCommand()
  call VimuxRunCommand('Up')
endfunction
map <C-e> :call RepeatLastTmuxCommand()<CR>

function! RunSomethingInTmux()
  if &filetype ==# 'markdown'
    call VimuxRunCommand("mdrr '" . expand('%') . "'")
  end
endfunction
map <A-e> :call RunSomethingInTmux()<CR>

" this is useful for debuggers etc
map <Space>b :call VimuxRunCommand(bufname("%") . ":" . line("."), 0)<CR>
map !b :call VimuxRunCommand(bufname("%") . ":" . line("."), 1)<CR>
" }}}
Plug 'skywind3000/asyncrun.vim'
" {{{
let g:asyncrun_open = 0 " Never open the quickfix for me
map !l :AsyncRun bash -lc 'ctags-build'<CR>
" }}}
Plug 'airblade/vim-gitgutter'
" {{{
nmap [h <Plug>(GitGutterPrevHunk)
let g:gitgutter_sign_priority=0
nmap ]h <Plug>(GitGutterNextHunk)
nmap !h :GitGutterQuickFix<CR>
nmap \h :GitGutterFold<CR>
nmap ,hd :Gdiff origin/master<CR>
nmap 'h :let g:gitgutter_diff_base = 'origin/master'<CR>
set updatetime=100
" }}}

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" {{{
map \t :NERDTreeToggle<CR>
" }}}
" Plug 'w0rp/ale'
" {{{
"let g:ale_sign_error = "✗"
"let g:ale_sign_warning = "⚠"
"let g:ale_kotlin_languageserver_executable = '/Users/work/src/kotlin-language-server/server/build/install/server/bin/kotlin-language-server'
"" let g:ale_kotlin_ktlint_executable = '/usr/local/bin/ktlint --disabled_rules=indent'
"let g:ale_fixers = {
"      \'rust': ['rustfmt'],
"      \'ruby': ['rubocop'],
"      \'go': ['gofmt'],
"      \'typescript': ['remove_trailing_lines', 'trim_whitespace', 'eslint'],
"      \'typescriptreact': ['eslint'],
"      \'javascript': ['remove_trailing_lines', 'trim_whitespace', 'eslint'],
"      \'javascriptreact': ['remove_trailing_lines', 'trim_whitespace', 'eslint'],
"      \'kotlin': ['ktlint'],
"      \'python': ['black', 'autoimport']
"    \}
"      "\'python': ['black', 'autoimport', 'yapf']
"" Note that many of these have to be installed first!
"      " \'rust': ['analyzer'],
"let g:ale_linters = {
"      \'javascript': [''],
"      \'ruby': ['rubocop'],
"      \'typescript': ['tsserver', 'eslint'],
"      \'typescriptreact': ['tsserver', 'eslint'],
"      \'go': ['gopls'],
"      \'rust': ['cargo'],
"      \'kotlin': ['languageserver', 'ktlint'],
"      \'python': ['black', 'pyls', 'pyright']
"      \}
"let g:ale_lint_delay = 1000
"" let g:ale_command_wrapper = '~/.bin/ale-command-wrapper'
"let g:ale_ruby_rubocop_executable = 'bundle'
"let g:ale_ruby_rubocop_options = '--except Style/StringLiterals --exclude Layout/LineLength'
"let g:ale_rust_cargo_check_tests = 1
"let g:ale_rust_cargo_check_examples = 1
"let g:ale_set_balloons = 1 " Show symbol information on mouseover
"" let g:ale_typescript_tsserver_use_global = 1 " has hack for more memory

"" Let's require everything to be explicit, because this is always a nightmare in
"" new files.
"let g:ale_linters_explicit = 1

"let g:ale_rust_rls_toolchain = 'nightly'
"" rustup component add rust-src
"let g:ale_rust_rls_executable = 'rust-analyzer'
"" let g:ale_rust_rls_config = {
"" 	\ 'rust': {
"" 		\ 'clippy_preference': 'on'
"" 	\ }
"" 	\ }

"let g:ale_set_highlights = 0 " signs are enough
"let g:ale_cursor_detail = 0
"let g:ale_close_preview_on_insert = 1

" }}}
Plug 'milkypostman/vim-togglelist'
Plug 'tpope/vim-endwise', { 'for': 'ruby' }
Plug 'tpope/vim-surround'
Plug 'tpope/vim-rhubarb'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
" {{{
map <leader>gs :Gstatus<CR>
map <leader>gc :Gcommit<CR>
" }}}
Plug 'AndrewRadev/splitjoin.vim'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-commentary'
" {{{
" }}}
Plug 'tpope/vim-obsession'
Plug 'terryma/vim-multiple-cursors'
Plug 'chriskempson/base16-vim'
" Plug 'bouk/vim-markdown', { 'branch': 'wikilinks' }
Plug 'dpelle/vim-LanguageTool'
Plug 'plasticboy/vim-markdown'
" {{
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_new_list_item_indent = 0
let g:vim_markdown_auto_insert_bullets = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_no_extensions_in_markdown = 0
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_autowrite = 1
set conceallevel=0

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
command! -range Emoji <line1>,<line2>s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g
" }}
Plug 'vim-ruby/vim-ruby', { 'for': 'ruby' }
" {{
let ruby_operators = 1
let ruby_space_errors = 1
let ruby_spellcheck_strings = 0
" }}
Plug 'vim-scripts/VimClojure', { 'for': 'clojure' }
Plug 'kchmck/vim-coffee-script'
Plug 'yuezk/vim-js'
Plug 'HerringtonDarkholme/yats.vim' " Typescript
Plug 'maxmellon/vim-jsx-pretty'
Plug 'derekwyatt/vim-scala', { 'for': 'scala' }
Plug 'fatih/vim-go', { 'for': 'go' }
" {{
let g:go_def_mapping_enabled = 0
let g:go_fmt_fail_silently = 1
let g:go_gopls_enabled = 0 " using ale
" }}
Plug 'elixir-editors/vim-elixir', { 'for': 'elixir' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }
" {{{
let g:rustfmt_autosave = 0
let g:rust_recommended_style = 1
" }}}
Plug 'cespare/vim-toml', { 'for': 'toml' }
Plug 'uarun/vim-protobuf'
Plug 'udalov/kotlin-vim'
Plug 'vim-python/python-syntax'
" {
let g:python_highlight_all = 1
" }
Plug 'peitalin/vim-jsx-typescript'
Plug 'jparise/vim-graphql'
Plug 'racer-rust/vim-racer'
Plug 'mmarchini/bpftrace.vim'
Plug 'Shirk/vim-gas'

call plug#end()

lua << EOF
-- FZF lua has its own preview window... so can't use with fzf-tmux :(
--local actions = require "fzf-lua.actions"
--local fzf = require('fzf-lua')
--fzf.setup {
--  fzf_bin = "fzf-tmux",
--  fzf_args = "-p90%,60%"},
--  fzf_opts = {
--    -- options are sent as `<left>=<right>`
--    -- set to `false` to remove a flag
--    -- set to '' for a non-value flag
--    -- for raw args use `fzf_args` instead
--    ['--ansi']        = '',
--    ['--prompt']      = '> ',
--    --['--info']        = 'inline',
--    --['--height']      = '100%',
--    --['--layout']      = 'reverse',
--  },
--}

  -- local saga = require 'lspsaga'
  -- saga.init_lsp_saga()
  local cmp = require'cmp'
  local lspconfig = require("lspconfig")

  local tabnine = require('cmp_tabnine.config')
  tabnine:setup({
    max_lines = 5000;
    max_num_results = 10;
    sort = true;
    run_on_every_keystroke = true;
    snippet_placeholder = '..';
  })

  --local format_config = require("lspkind").cmp_format({
  --    with_text = true,
  --    menu = ({
  --      buffer = "[Buffer]",
  --      nvim_lsp = "[LSP]",
  --      tabnine = "[TN]",
  --      luasnip = "[LuaSnip]",
  --      nvim_lua = "[Lua]",
  --      latex_symbols = "[Latex]",
  --    })
  --  })

  cmp.setup({
    --formatting = { format = format_config },
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- require'snippy'.expand_snippet(args.body) -- For `snippy` users.
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<Tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'vsnip' },
      { name = 'cmp_tabnine' },
      { name = 'nvim_lsp' },
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

require("trouble").setup {
    fold_open = "v", -- icon used for open folds
    fold_closed = ">", -- icon used for closed folds
    indent_lines = false, -- add an indent guide below the fold icons
    signs = {
        -- icons / text used for a diagnostic
        error = "error",
        warning = "warn",
        hint = "hint",
        information = "info"
    },
    use_lsp_diagnostic_signs = false -- enabling this will use the signs defined in your lsp client
}

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', '<C-[>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', ',ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-K>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gl', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
  buf_set_keymap('n', 'gL', '<cmd>lua vim.lsp.buf.workspace_symbol("")<CR>', opts)

  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', ',e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", ",f", "<cmd>lua vim.lsp.buf.formatting_seq_sync()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", ",f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
    augroup lsp_document_highlight
    autocmd! * <buffer>
    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
    augroup END
    ]], false)
  end
end

vim.diagnostic.config({virtual_text = false})

local lsp_installer = require("nvim-lsp-installer")
-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities
    }

    -- (optional) Customize the options passed to the server
    if server.name == "pyright" then
        opts.settings = {
            python = {
                pythonPath = "/opt/homebrew/bin/python3"
            }
        }
    end

    if server.name == "eslint" then
      opts.on_attach = function (client, bufnr)
          -- neovim's LSP client does not currently support dynamic capabilities registration, so we need to set
          -- the resolved capabilities of the eslint server ourselves!
          client.resolved_capabilities.document_formatting = true
          on_attach(client, bufnr)
      end
      opts.settings = {
          format = { enable = true }, -- this will enable formatting
      }
    end

    if server.name == "solargraph" then
      opts = {
       on_attach = on_attach,
       capabilities = capabilities,

       filetypes = { "ruby", "gemfile", "rakefile" },
       cmd_env = {
         GEM_HOME = "/Users/simon/.gem/ruby/3.0.1",
         GEM_PATH = "/Users/simon/.gem/ruby/3.0.1:/Users/simon/.rubies/ruby-3.0.1/lib/ruby/gems/3.0.0"
       },
       --root_dir = function() 
       --  return "/Users/simon/.rubies/ruby-3.0.1"
       --end,
       cmd = {
         "/Users/simon/.gem/ruby/3.0.1/bin/solargraph", "stdio"
       },
       settings = {
          solargraph = {
            commandPath = "/Users/simon/.gem/ruby/3.0.1/bin/solargraph",
            useBundler = true,
            bundlerPath = "/Users/simon/.rubies/ruby-3.0.1/bin/bundle"
          }
       }
      }
    end

    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
end)

local null_ls = require("null-ls")
null_ls.config({
    sources = {
      null_ls.builtins.diagnostics.flake8,
      null_ls.builtins.formatting.reorder_python_imports,
      null_ls.builtins.formatting.autopep8
    }
})
lspconfig["null-ls"].setup({
    on_attach = on_attach
})

-- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})]]

vim.lsp.set_log_level("debug")

local signs = { Error = "✗", Warn = "⚠", Hint = "h", Info = "i" }

for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local fzf = require("fzf")

-- command! ZKRT call fzf#run(fzf#wrap({
--         \ 'source': 'zk-related-tags "' .. bufname("%") .. '"',
--         \ 'options': '--ansi --exact --nth 2',
--         \ 'sink':    function("InsertSecondColumn")
--       \}))

function insert_line_at_cursor(text)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local _column = cursor[2]

  -- vim.api.nvim_buf_set_text(0, row, column, row, column, {text})
  vim.api.nvim_buf_set_lines(0, row, row, false, {text})
end

function insert_tag_at_cursor(text)
  local tag = string.match(text, "([#%a-]+)")
  insert_line_at_cursor(tag)
end

function ZettelkastenRelatedTags()
  -- We use fzf.vim because it supports fzf.vim
  vim.cmd [[
    function! CallLuaFunction(arg1)
      call v:lua.insert_tag_at_cursor(a:arg1)
    endfunction

    call fzf#run(fzf#wrap({'source': 'zk-related-tags "' .. bufname("%") .. '"', 'options': '--ansi --exact --nth 2', 'sink': function('CallLuaFunction')}))
  ]]
end

function ZettelkastenTags()
  vim.cmd [[
    function! CallLuaFunction(arg1)
      call v:lua.insert_tag_at_cursor(a:arg1)
    endfunction

    call fzf#run(fzf#wrap({'source': 'zkt-raw', 'options': '--ansi --exact --nth 2', 'sink': function('CallLuaFunction')}))
  ]]
end

local function get_visual_selection()
    -- Yank current visual selection into the 'v' register
    --
    -- Note that this makes no effort to preserve this register
    vim.cmd('noau normal! "vy"')
    return vim.fn.getreg('v')
end

local a = require "plenary/async"

GPT = function()
  local curl = require "plenary.curl"
  local iterators = require "plenary.iterators"
  local token = vim.fn.getenv("OPENAI_TOKEN")

  line1 = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
  line2 = vim.api.nvim_buf_get_mark(0, ">")[1]

  --local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local lines = vim.api.nvim_buf_get_lines(0, line1, line2, false)
  local file = table.concat(lines, "\n")
  local body = vim.fn.json_encode({
    prompt = file,
    max_tokens = 256,
    temperature = 0.7, -- risk-taking 0 to 1
    best_of = 1,
  })

  curl.post('https://api.openai.com/v1/engines/davinci/completions', {
    accept = 'application/json',
    headers = {
      authorization = 'Bearer ' .. token,
      ["content-type"] = 'application/json',
    },
    body = body,
    -- schedule_wrap schedules the callback so it has access to the Vim APIs.
    callback = vim.schedule_wrap(function(out)
      local gpt_ans = vim.fn.json_decode(out.body).choices[1].text
      local buffer = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_open_win(buffer, true, {
        relative = 'win', width=90, height=50, row=10, col=10,
        border = 'rounded', style = 'minimal'
      })
      local lines = iterators.lines(gpt_ans):tolist();
      vim.api.nvim_buf_set_lines(buffer, 0, 0, false, lines)
    end),
  })
end

EOF

" Have to be after deoplete for some reason
" call deoplete#custom#option({
" \ 'smart_case': v:true,
" \ 'prev_completion_mode': "prev_completion_mode",
" \ 'sources': {
" \   '_': ['tabnine', 'lsp', 'buffer'],
" \   'json': [],
" \   'kotlin': ['lsp', 'tabnine'],
" \   'rust': ['lsp', 'tabnine'],
" \   'python': ['lsp', 'tabnine'],
" \   'markdown': ['markdown_links', 'markdown_tags']
" \ }
" \ })

" autocmd FileType json call deoplete#custom#buffer_option('auto_complete', v:false)
" autocmd FileType markdown call deoplete#custom#buffer_option('ignore_sources', ['around', 'buffer', 'tabnine'])
" Don't completee in strings and comments
" call deoplete#custom#source('_',
"             \ 'disabled_syntaxes', ['Comment', 'String'])

" call deoplete#custom#var('tabnine', {
" \ 'line_limit': 2000,
" \ 'max_num_results': 20,
" \ })

filetype plugin indent on " Enable after Vundle loaded, #dunnolol

" Allow editing crontabs http://vim.wikia.com/wiki/Editing_crontab
set backupskip=/tmp/*,/private/tmp/* "
set undodir=~/.vim/undo
set noswapfile
set nowritebackup
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
" set backspace=2 " Backspace deletes 2 spaces
set backspace=indent,eol,start
set shiftwidth=2 " Even if there are tabs, preview as 2 spaces

" set list " Highlight trailings, stolen from @teoljungberg
" set listchars=tab:>-,trail:.,extends:>,precedes:<
" set listchars=trail:.,extends:>,precedes:<
autocmd FileType go,gitcommit,qf,gitset,gas,asm setlocal nolist
autocmd FileType json setlocal textwidth=0

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
map cf :let @* = expand("%:t")<CR>
" Yank the full current file pathk
map cF :let @* = expand("%:p")<CR>

" Rename current file, thanks Gary Bernhardt via Ben Orenstein
function! RenameFile()
  let old_name = expand('%')
  let new_name = input('New file name: ', expand('%'), 'file')
  if new_name != '' && new_name !=# old_name
    exec ':Move ' . fnameescape(new_name)
    redraw!
  endif
endfunction
nnoremap <leader>r :call RenameFile()<cr>

au BufNewFile,BufRead *.ejson,*.jsonl,*.avsc set filetype=json
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
set tags=.tags,./tags,tags;

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
  if expand("%:t") !~ '^[0-9]\+'
    return
  endif
  " syn region mkdFootnotes matchgroup=mkdDelimiter start="\[\["    end="\]\]"

  inoremap <expr> <plug>(fzf-complete-path-custom) fzf#vim#complete#path("rg --files -t md \| sed 's/^/[[/g' \| sed 's/$/]]/'")
  imap <buffer> [[ <plug>(fzf-complete-path-custom)

  function! s:CompleteTagsReducer(lines)
    if len(a:lines) == 1
      return "#" . a:lines[0]
    else
      return split(a:lines[1], '\t ')[1]
    end
  endfunction

  inoremap <expr> <plug>(fzf-complete-tags) fzf#vim#complete(fzf#wrap({
        \ 'source': 'zkt-raw',
        \ 'options': '--multi --ansi --nth 2 --print-query --exact --header "Enter without a selection creates new tag"',
        \ 'reducer': function('<sid>CompleteTagsReducer')
        \ }))
  imap <buffer> # <plug>(fzf-complete-tags)
endfunction

" Don't know why I can't get FZF to return {2}
function! InsertSecondColumn(line)
  " execute 'read !echo ' .. split(a:e[0], '\t')[1]
  exe 'normal! o' .. split(a:line, '\t')[1]
endfunction

command! ZKRT :lua ZettelkastenRelatedTags()
command! ZKT :lua ZettelkastenTags()
" command! -range GPT :lua require("plenary/async").run(GPT, function() end)
command! -range GPT :lua GPT()

" command! ZKRT call fzf#run(fzf#wrap({
"         \ 'source': 'zk-related-tags "' .. bufname("%") .. '"',
"         \ 'options': '--ansi --exact --nth 2',
"         \ 'sink':    function("InsertSecondColumn")
"       \}))

" command! ZKSIM call fzf#run(fzf#wrap({
"         \ 'source': 'zksim "' .. bufname("%") .. '"',
"         \ 'options': '--ansi --exact --nth 2',
"         \ 'sink':    function("InsertSecondColumn")
"       \}))

" command! ZKT call fzf#run(fzf#wrap({
"         \ 'source': 'zkt-raw "' .. bufname("%") .. '"',
"         \ 'options': '--ansi --exact --nth 2',
"         \ 'sink':    function("InsertSecondColumn")
"       \}))

autocmd BufNew,BufNewFile,BufRead /Users/simon/Documents/Zettelkasten/*.md call ZettelkastenSetup()

map \d :put =strftime(\"%Y-%m-%d\")<CR>

function! LookupDocsLanguage()
  if &filetype ==# 'c' || &filetype ==# 'cpp'
    call system(g:browser_new_tab "'https://www.google.com/search?q=" . expand('<cword>') . "&sitesearch=man7.org%2Flinux%2Fman-pages'")
  elseif &filetype ==# 'markdown'
    call system(g:browser_new_tab . "'https://google.com/search?q=define%20" . expand('<cword>') . "'")
  elseif &filetype ==# 'rust'
    " let crate_link = "file:///" . getcwd() . "/target/doc/settings.html?search=" . expand('<cword>')
    let stdlib_link = 'https://doc.rust-lang.org/std/?search=' . expand('<cword>')

    " let stdlib_tab = trim(system("chrome-cli list links | grep 'doc.rust-lang.org' | grep -oE '[0-9]+'"))
    " let crate_tab = trim(system("chrome-cli list links | grep '" . getcwd() . "' | grep -oE '[0-9]+'"))
    " let active_tab = trim(system("chrome-cli info | grep -Eo '\d+' | head -n1"))

    " if stdlib_tab
    "   call system("chrome-cli open " . stdlib_link . " -t " . stdlib_tab)
    " else
      " call system(browser . stdlib_link)
    " end

    " if crate_tab
      " call system(browser . " " . crate_link . " -t " . crate_tab)
      " if active_tab != stdlib_tab && active_tab != crate_tab
      "   call system("chrome-cli activate -t " . crate_tab)
      " end
    " else
      " call VimuxRunCommand("cargo doc &")
    call system(g:browser_new_tab . stdlib_link)
  elseif &filetype ==# 'ruby'
    " could prob make this use ri(1)
    call system(g:browser_new_tab . "https://ruby-doc.com/search.html?q=" . expand('<cword>'))
  elseif &filetype =~ "typescript" || &filetype =~ "javascript"
    call system(g:browser_new_tab . "https://devdocs.io/#q=js%20" . expand('<cword>'))
  else
    call system(g:browser_new_tab . "https://google.com/search?q=" . &filetype . "%20" . expand('<cword>'))
  endif
endfunction

function! LookupDocsLibrary()
  let browser = "/Applications/Firefox.app/Contents/MacOS/firefox --new-tab "
  call system(browser . "https://google.com/search?q=" . &filetype . "%20" . expand('<cword>'))
endfunction

" Docs/lint binds
nmap <C-k> :call LookupDocsLanguage()<cr>
" nmap <C-[> :ALEGoToDefinition<cr>
nmap <A-k> :call LookupDocsLibrary<CR>
" map <leader>f :ALEFix<CR>
map !f :call VimuxRunCommand("dev style")<CR>
" map [a :ALEPrevious<CR>
" map ]a :ALENext<CR>

" augroup remember_folds
"   autocmd!
"   autocmd BufWinLeave * mkview
"   autocmd BufWinEnter * silent! loadview
" augroup END

autocmd BufRead,BufNewFile *.py,*.py set expandtab tabstop=4 shiftwidth=4 softtabstop=4
autocmd FileType markdown setlocal commentstring=>\ %s
let g:python3_host_prog="/opt/homebrew/bin/python3"

autocmd FileType markdown lua require('cmp').setup.buffer { enabled = false }

imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
nmap        s   <Plug>(vsnip-select-text)
xmap        s   <Plug>(vsnip-select-text)
nmap        S   <Plug>(vsnip-cut-text)
xmap        S   <Plug>(vsnip-cut-text)

let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']

