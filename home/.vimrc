" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=1000  " Keep more history, default is 20
set mouse=v " Allow copy-pasting
set mmp=5000 " Some files need more memory for syntax highlight
" set autochdir
set tags=.tags,./tags,tags;

" <cword> then includes - as part of the word
set iskeyword+=-

" nvim-cmp asks for this
" set completeopt=menu,menuone,noselect

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

lua vim.cmd [[packadd packer.nvim]]
lua << EOF
vim.cmd [[
  augroup Packer
    autocmd!
    autocmd BufWritePost .vimrc PackerCompile
  augroup end
]]
-- REMEMBER TO RUN PackerSync, especially for opt = true!
-- TODO: Move all configuration in here
-- TODO: Lazy-load as much as possible
-- TODO: Convert configuration to Lua
return require('packer').startup(function()
  use 'wbthomason/packer.nvim'

  -- Completion -- 
  use 'ms-jpq/coq_nvim'
  use 'ms-jpq/coq.artifacts'
  use 'ms-jpq/coq.thirdparty'
  -- Maybe try https://github.com/ms-jpq/coq_nvim
  -- use 'hrsh7th/nvim-cmp'
  -- use {'tzachar/cmp-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-cmp'}
  -- use 'hrsh7th/cmp-nvim-lsp'
  -- use 'hrsh7th/cmp-buffer'
  -- use 'hrsh7th/cmp-path'
  -- use 'hrsh7th/cmp-cmdline'
  use {
    'jameshiew/nvim-magic',
    config = function()
      require('nvim-magic').setup()
      vim.cmd [[
        command! MDoc -range <Plug>nvim-magic-suggest-docstring	
      ]]
    end,
    requires = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim'
    }
  }
  -- Friendly Snippets --
  -- use 'hrsh7th/cmp-vsnip'
  -- use 'hrsh7th/vim-vsnip'
  -- use 'rafamadriz/friendly-snippets'

  -- TreeSitter --
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'windwp/nvim-ts-autotag'
  use 'nvim-treesitter/nvim-treesitter-textobjects' -- if / af for selection body
  use 'michaeljsmith/vim-indent-object'
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'romgrk/nvim-treesitter-context' -- Show context for code you're navigating in
  use 'tpope/vim-commentary'
  -- use {"lukas-reineke/indent-blankline.nvim", config = function() require("indent_blankline").setup() end}

  -- We rely on TreeSitter by default, but for some languages we may want more.
  --
  -- * List indentation
  -- * Make quote syntax nice and greyed out (like a comment)
  use {'preservim/vim-markdown', ft = {'markdown'}, config = function()
    vim.cmd [[
      let g:vim_markdown_new_list_item_indent = 2
      let g:vim_markdown_folding_disabled = 1
    ]]
  end }

  -- Lua --
  use 'nvim-lua/plenary.nvim' -- Utility functions

  -- Git --
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      if vim.g.gitgutter_diff_base then
        require('gitsigns').change_base(vim.g.gitgutter_diff_base, true)
      end
    end
  }
  use 'tpope/vim-rhubarb' -- Gbrowse
  use 'tpope/vim-fugitive'

  ----------------------
  -- Code Navigbation --
  ----------------------
  -- Lsp --
  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer' -- LspInstallInfo
  use 'jose-elias-alvarez/null-ls.nvim' -- Create LS from shell tools
  use 'folke/lsp-colors.nvim'
  use { 'kyazdani42/nvim-web-devicons',
    config = function() require('nvim-web-devicons').setup { default = true; } end,
    event = 'VimEnter'
  }

  -- Fzf -- 
  use { 'junegunn/fzf', run = './install --bin', }
  use 'junegunn/fzf.vim'
  use 'chengzeyi/fzf-preview.vim' -- Tag previews
  use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use {
    'nvim-telescope/telescope.nvim',
    requires = { {'nvim-lua/plenary.nvim'} },
    config = function()
      require('telescope').load_extension('fzf')
      require('telescope').setup()
    end
  }
  use {
    'ibhagwan/fzf-lua', -- Nifty LSP commands, doesn't support tmux
    config = function()
      actions = require "fzf-lua.actions"
      fzf = require('fzf-lua')
      fzf.setup {
        winopts = {
          height = 0.9,
          width = 0.9,
          preview = {
            flip_columns      = 200,        -- how many columns to allow vertical split
            winopts = {                       -- builtin previewer window options
              number            = false,
              relativenumber    = false,
            },
          }
        },
        -- fzf_args = "--keep-right --select-1",
        -- fzf_args = "--keep-right",
        fzf_opts = {
          -- options are sent as `<left>=<right>`
          -- set to `false` to remove a flag
          -- set to '' for a non-value flag
          -- for raw args use `fzf_args` instead
          ['--ansi']        = '',
          ['--prompt']      = '> ',
          ['--info']        = 'inline',
          ['--height']      = '100%',
          ['--layout']      = 'reverse',
        },
        tags = {
          fzf_opts = { ['--nth'] = '2' },
        },
      files = {
          previewer      = "bat",
        },
        actions = {
            buffers = {
                    ["default"]     = actions.buf_edit,
                    ["ctrl-x"]      = actions.buf_split,
                    ["ctrl-v"]      = actions.buf_vsplit,
                    ["ctrl-t"]      = actions.buf_tabedit,
            },
            files = {
                ["default"]     = actions.file_edit_or_qf,
                ["ctrl-x"]      = actions.file_split,
                ["ctrl-v"]      = actions.file_vsplit,
                ["ctrl-t"]      = actions.file_tabedit,
                ["alt-q"]       = actions.file_sel_to_qf,
            }
        }
      }

      vim.cmd [[
        map z= :lua require("fzf-lua").spell_suggest()<CR>
        map <A-j> :lua require("fzf-lua").git_status()<CR>
      ]]
    end
  }
  use 'vijaymarupudi/nvim-fzf' -- Lua api
  use {
    'majutsushi/tagbar',
    cmd = "TagbarToggle",
    keys = "\\l",
    config = function()
      vim.cmd [[
        nmap \l :TagbarToggle<CR>
        map <C-W>[ :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
        let g:tagbar_compact = 1
        let g:tagbar_indent = 1
      ]]
    end
  }

  -- Standard Vim ergonomics
  use 'norcalli/nvim-colorizer.lua'
  use 'milkypostman/vim-togglelist'
  use { 'scrooloose/nerdtree', keys = "\\t", config = function() vim.cmd [[ map \t :NERDTreeToggle<CR> ]] end }
  use { "tpope/vim-surround",
    keys = {"c", "d", "y"},
    config = function ()
      vim.cmd("nmap ds       <Plug>Dsurround")
      vim.cmd("nmap cs       <Plug>Csurround")
      vim.cmd("nmap cS       <Plug>CSurround")
      vim.cmd("nmap ys       <Plug>Ysurround")
      vim.cmd("nmap yS       <Plug>YSurround")
      vim.cmd("nmap yss      <Plug>Yssurround")
      vim.cmd("nmap ySs      <Plug>YSsurround")
      vim.cmd("nmap ySS      <Plug>YSsurround")
      vim.cmd("xmap gs       <Plug>VSurround")
      vim.cmd("xmap gS       <Plug>VgSurround")
      vim.cmd [[ let g:surround_111 = "**\r**" ]]
      vim.g.surround_111 = "**\\r**"
    end
  }
  use 'tpope/vim-eunuch' -- Unix commands
  use 'AndrewRadev/splitjoin.vim'
  use 'tpope/vim-unimpaired'
  use {
    'ggandor/lightspeed.nvim',
    config = function()
    require('lightspeed').setup({})
    end
  }
  use 'tpope/vim-repeat'
  -- use 'chriskempson/base16-vim' -- Colors
  use 'RRethy/nvim-base16'
  -- use 'tjdevries/train.nvim'
  use { 'takac/vim-hardtime', config = function()
    vim.cmd [[
      let g:hardtime_timeout = 1000
      let g:hardtime_showmsg = 1
      let g:hardtime_ignore_buffer_patterns = [ "NERD.*" ]
      let g:hardtime_ignore_quickfix = 1
      let g:hardtime_maxcount = 4
      let g:hardtime_default_on = 1
    ]]
  end}

  use 'janko-m/vim-test'
  use { "rcarriga/vim-ultest", requires = {"vim-test/vim-test"}, run = ":UpdateRemotePlugins" }
  use 'mfussenegger/nvim-dap'
  use 'benmills/vimux'
  use { 'skywind3000/asyncrun.vim', keys = "!l",
        config = function() vim.cmd [[ map !l :AsyncRun bash -lc 'ctags-build'<CR> ]] end }

  -- Languages -- 
  use { 'tpope/vim-endwise', ft = 'ruby' }
  use { 'junegunn/vim-emoji', config = function() 
      vim.cmd [[ command! -range Emoji <line1>,<line2>s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g ]]
    end }

  -- TODO: Periodically remove these until Treesitter indent support is good enough.
  use { 'vim-ruby/vim-ruby', ft = 'ruby' } -- Need it for the indent..

  -- use { 'vim-scripts/VimClojure', ft = 'clojure' }
  -- use { 'yuezk/vim-js', ft = 'javascript' }
  -- use { 'maxmellon/vim-jsx-pretty', ft = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' } }
  -- -- use { 'peitalin/vim-jsx-typescript', ft = { 'javascriptreact', 'typescriptreact' } }
  -- use { 'derekwyatt/vim-scala', ft = 'scala' }
  -- use { 'fatih/vim-go', ft = 'go' }
  -- use { 'elixir-editors/vim-elixir', ft = 'elixir' }
  -- use { 'rust-lang/rust.vim', ft = 'rust' }
  -- use { 'racer-rust/vim-racer', ft = 'rust' }
  -- use { 'cespare/vim-toml', ft = 'toml' }
  -- use { 'uarun/vim-protobuf', ft = 'protobuf' }
  -- use { 'udalov/kotlin-vim', ft = 'kotlin' }
  -- use { 'vim-python/python-syntax', ft = 'python' }
  -- use { 'jparise/vim-graphql', ft = 'graphql' }
  -- use { 'mmarchini/bpftrace.vim', ft = 'bpftrace' }

  -- maybe:
  -- https://github.com/mg979/vim-visual-multi
  -- use 'dpelle/vim-LanguageTool'
  -- use 'plasticboy/vim-markdown'
end)
EOF

if exists('$TMUX')
  let g:fzf_layout = { 'tmux': '-p90%,60%' }
  let g:fzf_preview_window = 'right:50%'
else
  let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
endif
let g:fzf_tags_command = 'bash -c "build-ctags"'

" function! FzfSpellSink(word)
"   exe 'normal! "_ciw'.a:word
" endfunction
" function! FzfSpell()
"   let suggestions = spellsuggest(expand("<cword>"))
"   return fzf#run(fzf#wrap({'source': suggestions, 'sink': function("FzfSpellSink"), 'window': { 'width': 0.6, 'height': 0.3 }}))
" endfunction
" nnoremap z= :call FzfSpell()<CR>

let g:fzf_history_dir = '~/.fzf-history'
" function! RipgrepFzf(query, fullscreen)
"   let command_fmt = 'rg --column --hidden --line-number --no-heading --color=always --smart-case %s || true'
"   let initial_command = printf(command_fmt, shellescape(a:query))
"   let reload_command = printf(command_fmt, '{q}')
"   let options = {'options': ['--phony', '--keep-right', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
"   if a:fullscreen
"     let options = fzf#vim#with_preview(options)
"   endif
"   call fzf#vim#grep(initial_command, 1, options, a:fullscreen)
" endfunction

" command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
" map <C-g> :RG<CR> " Completely use RG, don't use fzf's fuzzy-matching
map <C-g> :lua require('fzf-lua').live_grep()<CR>
" map <Space>/ :execute 'Rg ' . expand('<cword>')<CR>
" map <A-/> :BLines<CR>
map <A-/> :lua require('fzf-lua').lines()<CR>
map <Space>/ :lua require('fzf-lua').grep_cword()<CR>
map <Leader>/ :lua require('fzf-lua').grep()<CR>
" map <leader>/ :execute 'Rg ' . input('Rg/')<CR>

" Redefine so for long paths in e.g. Java we still get the filename.
" command! -bang -nargs=? -complete=dir Files
"   \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': '--keep-right'}), <bang>0)
" map <C-t> :Files<CR>
map <C-t> :lua require('fzf-lua').files()<CR>

" map <C-j> :Buffers<CR>
map <C-j> :lua require('fzf-lua').buffers()<CR>
" Git Status
" map <A-j> :GFiles?<CR>
" map <A-c> :Commands<CR>
" map <C-l> :FZFTags<CR>
map <C-l> :lua require('fzf-lua').tags()<CR>
" map <A-l> :FZFBTags<CR>
map <A-l> :lua require('fzf-lua').btags()<CR>
" map <Space>l :execute 'FZFTags ' . expand('<cword>')<CR>
map <Space>l :lua require('fzf-lua').tags({ fzf_opts = { ["--query"] = vim.fn.expand("<cword>") }})<CR>
map <Space><A-l> :lua require('fzf-lua').btags({ fzf_opts = { ["--query"] = vim.fn.expand("<cword>") }})<CR>
" map <Space><A-l> :execute 'FZFBTags ' . expand('<cword>')<CR>

set signcolumn=yes " always show the gutter... to avoid flickering from LSP, etc.

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

" {{{
let test#strategy = "vimux"
map <leader>t :UltestNearest<CR>
map <leader>T :Ultest<CR>
map <Space>t :UltestLast<CR>
" }}}

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

" let g:vim_markdown_folding_disabled = 1
" let g:vim_markdown_new_list_item_indent = 0
" let g:vim_markdown_auto_insert_bullets = 1
" let g:vim_markdown_frontmatter = 1
" let g:vim_markdown_no_extensions_in_markdown = 0
" let g:vim_markdown_follow_anchor = 1
" let g:vim_markdown_strikethrough = 1
" let g:vim_markdown_autowrite = 1
" set conceallevel=0


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

" let ruby_operators = 1
" let ruby_space_errors = 1
" let ruby_spellcheck_strings = 0
" " }}
" " {{
" let g:go_def_mapping_enabled = 0
" let g:go_fmt_fail_silently = 1
" let g:go_gopls_enabled = 0 " using ale
" " }}
" " {{{
" let g:rustfmt_autosave = 0
" let g:rust_recommended_style = 1
" }}}
" {
" let g:python_highlight_all = 1
" }

lua << EOF
require('gitsigns').setup {
  keymaps = {
    noremap = true,
    ['n ]h'] = { expr = true, "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'"},
    ['n [h'] = { expr = true, "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'"},
    ['n <leader>hs'] = '<cmd>Gitsigns stage_hunk<CR>',
    ['v <leader>hs'] = ':Gitsigns stage_hunk<CR>',
    ['n <leader>hu'] = '<cmd>Gitsigns undo_stage_hunk<CR>',
    ['n <leader>hr'] = '<cmd>Gitsigns reset_hunk<CR>',
    ['v <leader>hr'] = ':Gitsigns reset_hunk<CR>',
    ['n <leader>hR'] = '<cmd>Gitsigns reset_buffer<CR>',
    ['n <leader>hp'] = '<cmd>Gitsigns preview_hunk<CR>',
    ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line{full=true}<CR>',
    ['n <leader>hS'] = '<cmd>Gitsigns stage_buffer<CR>',
    ['n <leader>hU'] = '<cmd>Gitsigns reset_buffer_index<CR>',
    ['n <leader>hC'] = '<cmd>lua require"gitsigns".change_base(vim.g.gitgutter_diff_base or \'master\', true)<CR>',
    ['n <leader>hc'] = '<cmd>lua vim.ui.input({prompt = \'Change Git Base To: \', default = vim.g.gitgutter_diff_base}, function(input) require("gitsigns").change_base(input); end, true)<CR>'
  }
}

-- print("CHANGING! " .. vim.g.gitgutter_diff_base)
-- require('gitsigns').change_base(vim.g.gitgutter_diff_base, true)
require'nvim-treesitter.configs'.setup {
  autotag = {
    enable = true,
  },
  -- indent = {
  --   enable = true
  -- },
  context_commentstring = {
    enable = true,
    config = {
      markdown = '> %s'
    }
  },
  textobjects = {
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@conditional.outer",
        ["ic"] = "@conditional.inner",
        ["aC"] = "@class.outer",
        ["iC"] = "@class.inner",
        ["i/"] = "@comment.outer",
        ["iP"] = "@parameter.inner",
        ["aP"] = "@parameter.outer",
      },
    },
  },
}

require'nvim-treesitter.configs'.setup {
  context_commentstring = {
    enable = true
  }
}

-- require('dash').setup({
  -- your config here
-- })
-- FZF lua has its own preview window... so can't use with fzf-tmux :(
  -- local saga = require 'lspsaga'
  -- saga.init_lsp_saga()
  -- local cmp = require'cmp'
  local lspconfig = require("lspconfig")
  vim.g.coq_settings = {
    -- auto_start = 'shut-up',
    ['display.icons.mode'] = 'none',
    clients = {
      tabnine = { enabled = true },
      tmux = { enabled = true }
    }
  }
  local coq = require("coq")
  require("coq_3p") {
    { src = "copilot", short_name = "COP", accept_key = "<c-f>" },
    { src = "bc", short_name = "MATH", precision = 4 }
  }
  -- lua.coq_settings.clients.tabnine.enabled=true

  -- local tabnine = require('cmp_tabnine.config')
  -- tabnine:setup({
  --   max_lines = 5000;
  --   max_num_results = 10;
  --   sort = true;
  --   run_on_every_keystroke = true;
  --   snippet_placeholder = '..';
  -- })

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  --buf_set_keymap('n', '<C-[>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<C-[>', '<cmd>lua require(\'fzf-lua\').lsp_definitions({jump_to_single_result = true, async = true })<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-K>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', ',ca', '<cmd>lua require(\'fzf-lua\').lsp_code_actions()<CR>', opts)
  buf_set_keymap('v', ',ca', ":<c-u>lua vim.lsp.buf.range_code_action()<CR>", opts)
  buf_set_keymap('n', 'gr', "<cmd>lua require('fzf-lua').lsp_references()<CR>", opts)
  buf_set_keymap('n', '[e', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']e', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', ',E', "<cmd>lua require('fzf-lua').lsp_document_diagnostics()<CR>", opts)
  buf_set_keymap('n', ',e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'g<A-l>', "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>", opts)
  buf_set_keymap('n', 'gl', "<cmd>lua require('fzf-lua').lsp_live_workspace_symbols()<CR>", opts)

  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

  -- Set some keybinds conditional on server capabilities
  -- if client.resolved_capabilities.document_formatting then
  buf_set_keymap("n", ",f", "<cmd>lua vim.lsp.buf.formatting_seq_sync({}, 10000)<CR>", opts)
  buf_set_keymap("n", ",F", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
  -- end

  if client.resolved_capabilities.document_range_formatting then
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

local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
local opts = { noremap=true, silent=true }

vim.diagnostic.config({virtual_text = false})

local lsp_installer = require("nvim-lsp-installer")
-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
    local opts = {
      on_attach = on_attach,
      capabilities = capabilities
    }

    if server.name == "elm" then
        opts.settings = {
            rootMarkers = {".git/"},
            languages = {
                python = {
                    {
                            lintCommand = "flake8 --stdin-display-name ${INPUT} -",
                            formatStdin = true,
                            lintFormats = { '%f:%l:%c: %m' }
                    }
                }
            }
        }
    end

    -- (optional) Customize the options passed to the server
    if server.name == "pyright" then
        opts.settings = {
            python = {
                pythonPath = "/opt/homebrew/bin/python3"
            }
        }
    end

    -- if server.name == "eslint" then
    --   opts.on_attach = function (client, bufnr)
    --       -- neovim's LSP client does not currently support dynamic capabilities registration, so we need to set
    --       -- the resolved capabilities of the eslint server ourselves!
    --       client.resolved_capabilities.document_formatting = true
    --       on_attach(client, bufnr)
    --   end
    --   opts.settings = {
    --       format = { enable = true }, -- this will enable formatting
    --   }
    -- end

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
    server:setup(coq.lsp_ensure_capabilities(opts))
end)

require("null-ls").setup({
    debug = true,
    sources = {
        require("null-ls").builtins.diagnostics.flake8,
        require("null-ls").builtins.diagnostics.eslint,
        require("null-ls").builtins.diagnostics.hadolint,
        require("null-ls").builtins.diagnostics.jsonlint,
        require("null-ls").builtins.formatting.autopep8,
        require("null-ls").builtins.formatting.isort,
        require("null-ls").builtins.formatting.eslint_d,
        require("null-ls").builtins.formatting.fixjson,
        require("null-ls").builtins.formatting.stylua,
        require("null-ls").builtins.code_actions.gitsigns,
    },
})

-- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float({focusable=false})]]

vim.lsp.set_log_level("info")

--local signs = { Error = "✗", Warn = "⚠", Hint = "h", Info = "i" }
--local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }

-- for type, icon in pairs(signs) do
--   local hl = "DiagnosticSign" .. type
--   vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end
--
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

require'nvim-treesitter.configs'.setup {
  ensure_installed = "maintained", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
  -- ignore_install = { "javascript" }, -- List of parsers to ignore installing
  highlight = {
    enable = true,              -- false will disable the whole extension
    -- disable = { "c", "rust" },  -- list of language that will be disabled
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
EOF

filetype plugin indent on

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
" autocmd FileType go,gitcommit,qf,gitset,gas,asm setlocal nolist
" autocmd FileType json setlocal textwidth=0

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
" function! InsertSecondColumn(line)
  " execute 'read !echo ' .. split(a:e[0], '\t')[1]
  " exe 'normal! o' .. split(a:line, '\t')[1]
" endfunction

command! ZKRT :lua ZettelkastenRelatedTags()
command! ZKT :lua ZettelkastenTags()
command! -range GPT :lua GPT()

map \d :put =strftime(\"# %Y-%m-%d\")<CR>

au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=80 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

let g:python3_host_prog="/opt/homebrew/bin/python3"

" imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
" smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

" " Expand or jump
" imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
" smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" " Jump forward or backward
" imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
" imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
" smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
" nmap        s   <Plug>(vsnip-select-text)
" xmap        s   <Plug>(vsnip-select-text)
" nmap        S   <Plug>(vsnip-cut-text)
" xmap        S   <Plug>(vsnip-cut-text)

let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']

au BufNewFile,BufRead *.tsx set filetype=typescriptreact
au BufNewFile,BufRead *.jsx set filetype=javascriptreact
au BufNewFile,BufRead *.ejson,*.jsonl,*.avsc set filetype=json
au BufNewFile,BufRead *.s set filetype=gas
" au FileType markdown lua require('cmp').setup.buffer { enabled = false }
au FileType markdown setlocal commentstring=>\ %s
au BufNew,BufNewFile,BufRead /Users/simon/Documents/Zettelkasten/*.md call ZettelkastenSetup()
autocmd FileType markdown setlocal spell
autocmd FileType markdown setlocal linebreak " wrap on words, not characters

let g:surround_{char2nr('b')} = "**\r**"
