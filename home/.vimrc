" BASIC
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=1000  " Keep more history, default is 20
set mouse=v " Allow copy-pasting
set autoread " Update the file automatically if changed and buffer isn't modified, e.g. external linter
set tags=.tags,./tags,tags;
set signcolumn=yes " always show the gutter... to avoid flickering from LSP, etc.
" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect
set shortmess+=c

" <cword> then includes - as part of the word
set iskeyword+=-

" set termguicolors
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

  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-emoji'
  use 'hrsh7th/cmp-vsnip'
  use 'hrsh7th/vim-vsnip'
  use "kdheepak/cmp-latex-symbols"
  use "rafamadriz/friendly-snippets"

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

  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use 'andymass/vim-matchup'
  use 'windwp/nvim-ts-autotag'
  use 'RRethy/nvim-treesitter-endwise'
  use 'nvim-treesitter/nvim-treesitter-textobjects' -- if / af for selection body
  use 'michaeljsmith/vim-indent-object'
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use 'romgrk/nvim-treesitter-context' -- Show context for code you're navigating in
  use 'tpope/vim-commentary'
  use 'tpope/vim-sleuth' -- Set shiftwidth automatically
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
          ['n <leader>hc'] = '<cmd>lua vim.ui.input({prompt = \'Change Git Base To: \', default = vim.g.gitgutter_diff_base}, function(input) require("gitsigns").change_base(input, true); end, true)<CR>'
        }
      }
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
  use { 'jose-elias-alvarez/null-ls.nvim', -- Create LS from shell tools
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
          debug = true,
          sources = {
              null_ls.builtins.diagnostics.flake8,
              -- null_ls.builtins.diagnostics.eslint,
              null_ls.builtins.diagnostics.hadolint,
              null_ls.builtins.diagnostics.jsonlint,
              null_ls.builtins.formatting.autopep8,
              null_ls.builtins.formatting.isort,
              -- null_ls.builtins.formatting.eslint_d,
              null_ls.builtins.formatting.fixjson,
              null_ls.builtins.formatting.stylua,
              null_ls.builtins.code_actions.gitsigns,
              null_ls.builtins.formatting.goimports
          }
      })
    end,
  }

  use 'folke/lsp-colors.nvim'
  use { 'kyazdani42/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup {
        default = true;
      }
    end,
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
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      actions = require "fzf-lua.actions"
      fzf = require('fzf-lua')
      fzf.setup {
        winopts = {
          preview = { default = 'bat_native' },
          height = 0.9,
          width = 0.9,
          preview = {
            -- default = 'bat',
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
          -- Don't follow symlinks, weird behavior in JS repos.
          fd_opts           = "--color=never --type f --hidden --exclude .git",
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
        },
        buffers = {
          actions = {
            ["ctrl-x"]          = actions.buf_split,
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
  -- use { 'scrooloose/nerdtree', keys = "\\t", config = function() vim.cmd [[ map \t :NERDTreeToggle<CR> ]] end }
  -- use { 'scrooloose/nerdtree' }
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
      vim.g.surround_111 = "**\\r**"
      vim.cmd [[ let g:surround_111 = "**\r**" ]]
      vim.cmd [[ let g:surround_{char2nr('b')} = "**\r**" ]]
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
  -- use { 'takac/vim-hardtime', config = function()
  --   vim.cmd [[
  --     let g:hardtime_timeout = 1000
  --     let g:hardtime_showmsg = 1
  --     let g:hardtime_ignore_buffer_patterns = [ "NERD.*" ]
  --     let g:hardtime_ignore_quickfix = 1
  --     let g:hardtime_maxcount = 4
  --     let g:hardtime_default_on = 1
  --   ]]
  -- end}

  use 'janko-m/vim-test'
  use { "rcarriga/vim-ultest", requires = {"vim-test/vim-test"}, run = ":UpdateRemotePlugins" }
  use 'mfussenegger/nvim-dap'
  use 'benmills/vimux'
  use { 'skywind3000/asyncrun.vim', keys = "!l",
        config = function() vim.cmd [[ map !l :AsyncRun bash -lc 'ctags-build'<CR> ]] end }

  -- Languages -- 
  use { 'junegunn/vim-emoji', config = function() 
      vim.cmd [[ command! -range Emoji <line1>,<line2>s/:\([^:]\+\):/\=emoji#for(submatch(1), submatch(0))/g ]]
    end }

  use {
    'kyazdani42/nvim-tree.lua',
    requires = {
        'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    config = function()
      require'nvim-tree'.setup {}
      vim.cmd [[ map \t :NvimTreeToggle<CR> ]]
    end
  }

  -- TODO: Periodically remove these until Treesitter indent support is good enough.
  use { 'vim-ruby/vim-ruby', ft = 'ruby' } -- Need it for the indent..
  -- use { 'vim-crystal/vim-crystal' }
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
end)
EOF

" TODO: Remove this by converting the Zettelkasten stuff to fzf-lua.
if exists('$TMUX')
  let g:fzf_layout = { 'tmux': '-p90%,60%' }
  let g:fzf_preview_window = 'right:50%'
else
  let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
endif
let g:fzf_tags_command = 'bash -c "build-ctags"'
let g:fzf_history_dir = '~/.fzf-history'

map <C-g> :lua require('fzf-lua').live_grep()<CR>
map <A-/> :lua require('fzf-lua').lines()<CR>
map <Space>/ :lua require('fzf-lua').grep_cword()<CR>
map <Leader>/ :lua require('fzf-lua').grep()<CR>
map <C-t> :lua require('fzf-lua').files()<CR>
map <C-j> :lua require('fzf-lua').buffers()<CR>
map <C-l> :lua require('fzf-lua').tags()<CR>
map <A-l> :lua require('fzf-lua').btags()<CR>
map <Space>l :lua require('fzf-lua').tags({ fzf_opts = { ["--query"] = vim.fn.expand("<cword>") }})<CR>
map <Space><A-l> :lua require('fzf-lua').btags({ fzf_opts = { ["--query"] = vim.fn.expand("<cword>") }})<CR>

" TODO: Rewrite these in Lua. Would be a good plugin..
" function! FzfGem(name)
"   let path = system("bundle info ".a:name." | rg -oP '(?<=Path: )(.+)$'")
"   let path = substitute(path, '\n', '', '')
"   execute ":FZF " . path
" endfunction
" command! -nargs=* FZFGem call FzfGem(<f-args>)

" function! Gem(name)
"   let path = system("bundle info ".a:name." | rg -oP '(?<=Path: )(.+)$'")
"   let path = substitute(path, '\n', '', '')
"   silent execute ":!tmux new-window -n 'gem:" . a:name . "' bash -l -c 'cd " . path . " && /opt/homebrew/bin/nvim -c \':FZF\''"
" endfunction
" command! -nargs=* Gem call Gem(<f-args>)

" function! Crate(name)
"   let path = system("bash -c \"cargo metadata --format-version 1 | rb 'from_json[:packages].find { |c| c[:name] =~ /" . a:name . "/ }[:targets][0][:src_path]'\"")
"   let path = substitute(path, '\n', '', '')
"   let dir_path = fnamemodify(path, ':p:h') . "/../"
"   silent execute ":!tmux new-window -n 'crate:" . a:name . "' bash -c 'cd " . dir_path . " && vim -c \':FZF\''"
" endfunction
" command! -nargs=* Crate call Crate(<f-args>)

" function! FzfCrate(name)
"   let path = system("bash -c \"cargo metadata --format-version 1 | rb 'from_json[:packages].find { |c| c[:name] =~ /" . a:name . "/ }[:targets][0][:src_path]'\"")
"   let path = substitute(path, '\n', '', '')
"   let dir_path = fnamemodify(path, ':p:h') . "/../"
"   execute ":FZF " . dir_path
" endfunction
" command! -nargs=* FZFCrate call FzfCrate(<f-args>)

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
" let g:VimuxTmuxCommand = "/opt/homebrew/bin/tmux"
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

lua << EOF
local cmp = require'cmp'

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

  cmp.setup({
    enabled = function()
      if require"cmp.config.context".in_treesitter_capture("comment")==true or require"cmp.config.context".in_syntax_group("Comment") then
        return false
      else
        return true
      end
    end,
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    mapping = {
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif vim.fn["vsnip#available"](1) == 1 then
          feedkey("<Plug>(vsnip-expand-or-jump)", "")
        elseif has_words_before() then
          cmp.complete()
        else
          fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function()
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.fn["vsnip#jumpable"](-1) == 1 then
          feedkey("<Plug>(vsnip-jump-prev)", "")
        end
      end, { "i", "s" }),

      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    },
    sources = cmp.config.sources({
      { name = 'emoji' },
      { name = "latex_symbols" },
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
    }, {
      { name = 'buffer' },
    })
  })
  cmp.setup.filetype('markdown', {
    sources = cmp.config.sources({
    }, {
    })
  })


-- print("CHANGING! " .. vim.g.gitgutter_diff_base)
-- require('gitsigns').change_base(vim.g.gitgutter_diff_base, true)
require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  ignore_install = { "phpdoc" },
  sync_install = false,
  matchup = {
    enable = true,
  },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  autotag = {
    enable = true,
  },
  endwise = {
    enable = true
  },
  indent = {
    enable = true
  },
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

  local lspconfig = require("lspconfig")
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }
  -- This broke in Neovim 0.7
  -- https://github.com/neovim/neovim/issues/17867 then map to C-[
  -- buf_set_keymap('n', '<C-[>', '<cmd>lua require(\'fzf-lua\').lsp_definitions({jump_to_single_result = true })<CR>', opts)
  buf_set_keymap('n', '<C-[>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '[[', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  -- buf_set_keymap('n', '<C-[>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  -- buf_set_keymap('n', '<Esc>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<Esc>', '<cmd>lua require(\'fzf-lua\').lsp_definitions({jump_to_single_result = true })<CR>', opts)

  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-K>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', ',ca', '<cmd>lua require(\'fzf-lua\').lsp_code_actions()<CR>', opts)
  buf_set_keymap('v', ',ca', ":<c-u>lua vim.lsp.buf.range_code_action()<CR>", opts)
  buf_set_keymap('n', 'gr', "<cmd>lua require('fzf-lua').lsp_references()<CR>", opts)
  buf_set_keymap('n', '[e', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>', opts)
  buf_set_keymap('n', ']e', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>', opts)
  buf_set_keymap('n', '[E', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']E', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', ',e', "<cmd>lua require('fzf-lua').lsp_document_diagnostics()<CR>", opts)
  buf_set_keymap('n', ',E', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua require(\'fzf-lua\').lsp_workspace_diagnostics()<CR>', opts)
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

  -- if client.resolved_capabilities.document_range_formatting then
  --   buf_set_keymap("n", ",f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  -- end

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
    opts.capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

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

    if server.name == "clangd" then
      if opts.capabilities then
        opts.capabilities.offsetEncoding = { "utf-16" }
      else
        opts.capabilities = { offsetEncoding = "utf-16" }
      end
    end

    -- if server.name == "eslint" then
    --   local eslint_config = require("lspconfig.server_configurations.eslint")
    --   opts.on_attach = function (client, bufnr)
    --       -- neovim's LSP client does not currently support dynamic capabilities registration, so we need to set
    --       -- the resolved capabilities of the eslint server ourselves!
    --       client.resolved_capabilities.document_formatting = true
    --       on_attach(client, bufnr)
    --   end
    --   -- print(eslint_config.default_config.cmd[1]);
    --   opts.settings = {
    --       format = { enable = true }, -- this will enable formatting
    --       -- cmd = { "yarn", unpack(eslint_config.default_config.cmd) }
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

    if server.name == "rust_analyzer" then
      opts = {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = {
              command = "clippy"
            }
          }
        }
      }
    end

    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    -- if vim.g.coq_enabled then
    --   local coq = require("coq") 
    server:setup(opts)
    -- end
end)

-- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focusable=false})]]

vim.lsp.set_log_level("info")
--
local fzf = require("fzf")
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
map \D :put =strftime(\"%Y-%m-%d\")<CR>

au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set textwidth=80 |
    \ set expandtab |
    \ set autoindent |
    \ set fileformat=unix

let g:python3_host_prog="/opt/homebrew/bin/python3"
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

