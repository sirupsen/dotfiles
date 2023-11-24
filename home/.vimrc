if exists('g:vscode')
  imap jk <esc>
else

" BASIC
set notermguicolors
set nocompatible " No vi compatility, this first because it resets some options
let mapleader="," " Mapleader
filetype off
set encoding=utf-8
set history=1000  " Keep more history, default is 20
set mouse=v " Allow copy-pasting
set autoread " Update the file automatically if changed and buffer isn't modified, e.g. external linter
set tags=.tags,./tags,tags;
set signcolumn=yes " always show the gutter... to avoid flickering from LSP, etc.
set shortmess+=c
let g:python3_host_prog="/Users/simon/.asdf/shims/python"

" <cword> then includes - as part of the word
set iskeyword+=-

set nospell
" allow spaces in file-names, which makes gf more useful
set isfname+=32
set hidden

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
augroup Packer
  autocmd!
  autocmd BufWritePost ~/.vimrc PackerCompile
augroup end

lua << EOF

simon_on_attach = function(client, bufnr)
   local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
   local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

   buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
   -- print(client.name, "attached")

   -- Mappings.
   local opts = { noremap=true, silent=true }
   -- This broke in Neovim 0.7
   -- https://github.com/neovim/neovim/issues/17867 then map to C-[
   -- buf_set_keymap('n', '<C-[>', '<cmd>lua require(\'fzf-lua\').lsp_definitions({jump_to_single_result = true })<CR>', opts)
   -- buf_set_keymap('n', '[[', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
   -- buf_set_keymap('n', '<C-[>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
   -- buf_set_keymap('n', '<Esc>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
   buf_set_keymap('n', '<C-[>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
   buf_set_keymap('n', '<Esc>', '<cmd>lua require(\'fzf-lua\').lsp_definitions({jump_to_single_result = true })<CR>', opts)
   buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

   buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
   buf_set_keymap('n', '<C-K>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
   buf_set_keymap('n', ',ca', '<cmd>lua require(\'fzf-lua\').lsp_code_actions()<CR>', opts)
   buf_set_keymap('v', ',ca', '<cmd>lua require(\'fzf-lua\').lsp_code_actions()<CR>', opts)
   -- buf_set_keymap('v', ',ca', '<cmd>lua require(\'fzf-lua\').lsp_code_actions()<CR>', opts)
   -- buf_set_keymap('v', ',ca', ":<c-u>lua vim.lsp.buf.code_action()<CR>", opts)
   buf_set_keymap('n', 'gr', "<cmd>lua require('fzf-lua').lsp_finder()<CR>", opts)
   buf_set_keymap('n', '[e', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>', opts)
   buf_set_keymap('n', ']e', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>', opts)
   buf_set_keymap('n', '[E', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
   buf_set_keymap('n', ']E', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
   buf_set_keymap('n', ',e', "<cmd>lua require('fzf-lua').lsp_document_diagnostics()<CR>", opts)
   buf_set_keymap('n', ',E', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
   buf_set_keymap('n', '<space>e', '<cmd>lua require(\'fzf-lua\').lsp_workspace_diagnostics()<CR>', opts)
   buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
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
   buf_set_keymap("n", ",f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
   buf_set_keymap("v", ",f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
   -- end

   -- if client.resolved_capabilities.document_range_formatting then
   --   buf_set_keymap("n", ",f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
   -- end

   -- Set autocommands conditional on server_capabilities
   -- if client.resolved_capabilities.document_highlight then
   --   vim.api.nvim_exec([[
   --   augroup lsp_document_highlight
   --   autocmd! * <buffer>
   --   autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
   --   autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
   --   augroup END
   --   ]], false)
   -- end
 end
-- Need it here for null_ls and for mason
-- REMEMBER TO RUN PackerSync, especially for opt = true!
-- TODO: Move all configuration in here
-- TODO: Lazy-load as much as possible
-- TODO: Convert configuration to Lua
return require('packer').startup(function()
  local enable_all = function() return true end

  use 'wbthomason/packer.nvim'

  -- use {'github/copilot.vim' }

  -- use({
  --   "dpayne/CodeGPT.nvim",
  --   requires = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-lua/plenary.nvim",
  --   },
  --   config = function()
  --     require("codegpt.config")
  --   end
  -- })
  -- or https://github.com/Robitx/gp.nvim
  -- use { 'sourcegraph/sg.nvim', run = 'nvim -l build/init.lua' }

  use({
      "robitx/gp.nvim",
      config = function()
          require("gp").setup()
      end,
  })

--   use({
--   "jackMort/ChatGPT.nvim",
--     config = function()
--       require("chatgpt").setup({
--          openai_params = { 
--            model = "gpt-4", 
--            frequency_penalty = 0, 
--            presence_penalty = 0, 
--            max_tokens = 300, 
--            temperature = 0, 
--            top_p = 1, 
--            n = 1, 
--          },
--          openai_edit_params = { 
--            model = "gpt-4", 
--            frequency_penalty = 0, 
--            presence_penalty = 0, 
--            max_tokens = 300, 
--            temperature = 0, 
--            top_p = 1, 
--            n = 1, 
--          },
--         -- keymaps = {
--         --   submit = "<C-s>"
--         -- }
--       })
--     end,
--     requires = {
--       "MunifTanjim/nui.nvim",
--       "nvim-lua/plenary.nvim",
--       "nvim-telescope/telescope.nvim"
--     }
--   })

  use {
    "zbirenbaum/copilot.lua",
    event = {"VimEnter"},
    config = function()
      -- vim.defer_fn(function()
        require("copilot").setup {
          server_opts_overrides = {
            settings = {
              advanced = {
                listCount = 10, -- #completions for panel
                inlineSuggestCount = 3, -- #completions for getCompletions
              }
            },
          },
          filetypes = {
          },
          suggestion = {
            auto_trigger = false,
            debounce = 1000,
            keymap = {
              next = "<C-j>",
              prev = "<C-k>",
              accept = "<C-l>",
            }
          },
          panel = {
            enabled = true,
            auto_refresh = false,
            keymap = {
              jump_prev = "[[",
              jump_next = "]]",
              accept = "<CR>",
              refresh = "gr",
              open = "<C-h>"
            },
          },
        }
      -- end, 100)
    end,
  }

  use {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function ()
      require("copilot_cmp").setup {
        method = "getCompletionsCycling",
      }
    end
  }

  use { 'hrsh7th/cmp-nvim-lsp'}
  use { 'hrsh7th/cmp-buffer'}
  use { 'hrsh7th/cmp-path'}
  use { 'hrsh7th/cmp-cmdline'}
  use { "kdheepak/cmp-latex-symbols"}

  use { 'hrsh7th/nvim-cmp'}

  use { 'hrsh7th/vim-vsnip'}
  use { 'hrsh7th/cmp-vsnip'}
  use { "rafamadriz/friendly-snippets"}
  -- https://github.com/mrjones2014/dash.nvim/issues/25
  -- use({
  --   'mrjones2014/dash.nvim',
  --   run = 'make install',
  --   config = function()
  --     require('dash').setup({
  --       file_type_keywords = {
  --         python = { 'py', 'torch', 'pandas', 'scikit' }
  --       }
  --     })
  --   end
  -- })


  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  -- use 'andymass/vim-matchup'
  use 'windwp/nvim-ts-autotag'
  use 'RRethy/nvim-treesitter-endwise'
  use 'nvim-treesitter/nvim-treesitter-textobjects' -- if / af for selection body
  use({
    "arsham/indent-tools.nvim",
    requires = { "arsham/arshlib.nvim" },
    config = function() require("indent-tools").config({}) end,
    -- keys = { "]i", "[i", { "v", "ii" }, { "o", "ii" } },
  })
  use 'nvim-treesitter/nvim-treesitter-context'
  use 'michaeljsmith/vim-indent-object'
  use { 
    'JoosepAlviste/nvim-ts-context-commentstring',
    config = function()
      vim.g.skip_ts_context_commentstring_module = true
    end
  }
  use 'tpope/vim-commentary'
  use 'tpope/vim-sleuth' -- Set shiftwidth automatically
  use 'editorconfig/editorconfig-vim'

  ---- Lua --
  use 'nvim-lua/plenary.nvim' -- Utility functions
  use "MunifTanjim/nui.nvim"

  -- Git --
  use {
    -- https://github.com/lewis6991/gitsigns.nvim has deprecated `keymaps`, switch to the new one in the README.
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      -- if vim.g.gitgutter_diff_base then
      --   require('gitsigns').change_base(vim.g.gitgutter_diff_base, true)
      -- end

      require('gitsigns').setup {
          current_line_blame = true,
          current_line_blame_opts = {
            delay = 2000,
          },
          on_attach = function(bufnr)
              local gs = package.loaded.gitsigns
              if vim.g.gitgutter_diff_base then
                gs.change_base(vim.g.gitgutter_diff_base, true)
              end

              local function map(mode, l, r, opts)
                opts = opts or {}
                opts.buffer = bufnr
                vim.keymap.set(mode, l, r, opts)
              end

              -- Navigation
              map('n', ']h', function()
                if vim.wo.diff then return ']h' end
                vim.schedule(function() gs.next_hunk() end)
                return '<Ignore>'
              end, {expr=true})

              map('n', '[h', function()
                if vim.wo.diff then return '[h' end
                vim.schedule(function() gs.prev_hunk() end)
                return '<Ignore>'
              end, {expr=true})

              -- Actions
              map({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>')
              map({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>')
              map('n', '<leader>hS', gs.stage_buffer)
              map('n', '<leader>hu', gs.undo_stage_hunk)
              map('n', '<leader>hR', gs.reset_buffer)
              map('n', '<leader>hp', gs.preview_hunk)
              map('n', '<leader>hB', function() gs.blame_line{full=true} end)
              map('n', '<leader>hb', gs.toggle_current_line_blame)

              -- if not vim.g.gitgutter_main_branch then
              --   vim.g.gitgutter_main_branch = vim.api.nvim_exec("!git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'", true):sub(0, -2)
              -- end
              -- map('n', '<leader>hm', function() gs.change_base(vim.g.gitgutter_main_branch, true) end)
              -- map('n', '<leader>hM', function() gs.change_base(nil, true) end)

              map('n', '<leader>hd', gs.diffthis)
              map('n', '<leader>hD', function() gs.diffthis('~') end)

              -- map('n', '<leader>he', gs.toggle_deleted)

              -- map('n', '<leader>hc', vim.ui.input({prompt = 'Change Git Base To: ', default = vim.g.gitgutter_diff_base}, function(input) gs.change_base(input, true); end, true))

              -- Text object
              map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
          end

        }
    end
  }
  use 'tpope/vim-rhubarb' -- Gbrowse
  use 'tpope/vim-fugitive'

  ------------------------
  ---- Code Navigbation --
  ------------------------
  -- Lsp --
  use { 'williamboman/mason.nvim', config = function() 
    -- require("mason").setup({})
  end
  }

  use {'williamboman/mason-lspconfig.nvim', config = function()
    require("mason").setup()
    require("mason-lspconfig").setup()
    require("mason-lspconfig").setup_handlers({
        -- The first entry (without a key) will be the default handler
        -- and will be called for each installed server that doesn't have
        -- a dedicated handler.
        function (server_name) -- default handler (optional)
            -- Basically just https://github.com/neovim/nvim-lspconfig
            require("lspconfig")[server_name].setup {
              on_attach = simon_on_attach,
            }
        end,

        ["rust_analyzer"] = function ()
            require("rust-tools").setup {}
            require("lspconfig")["rust_analyzer"].setup {
              on_attach = simon_on_attach,
              settings = {
                ["rust-analyzer"] = {
                  checkOnSave = {
                    command = "clippy"
                  },
                  diagnostics = {
                    disabled = {"inactive-code"}
                  }
                }
              }
            }
        end
    })
  end
  }

  use 'neovim/nvim-lspconfig'

  use {'WhoIsSethDaniel/mason-tool-installer.nvim', config = function()
      require'mason-tool-installer'.setup {
        ensure_installed = {
          'lua-language-server',
          'stylua',

          'bash-language-server',
          'shellcheck',
          'shfmt',

          'tailwindcss-language-server',

          'vim-language-server',

          'rust-analyzer',

          'dockerfile-language-server',
          'hadolint', -- Dockerfiles

          'fixjson',
          'json-lsp',

          -- writing
          -- 'remark-language-server',

          'goimports',
          'gofumpt',
          'gopls',
          'staticcheck',
          'vint',

          -- python
          'autopep8',
          'black',
          -- 'pyright', 'pyre',
          'mypy',
          'ruff',
          'isort',
          'flake8',

          'solargraph',

          'sql-formatter',

          'typescript-language-server',
          'eslint-lsp',
        }
      }
  end }

  use { 'jose-elias-alvarez/null-ls.nvim', -- Create LS from shell tools
    -- Probably need to do this https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md#using-local-executables
    config = function()
      local null_ls = require("null-ls")
      local methods = require("null-ls.methods")
      null_ls.setup({
          on_attach = simon_on_attach,
          -- debug = true,
          sources = {
              -- How to install plugins when installed by Mason..?
              --   1. cd to ~/.local/share/nvim/mason/packages/flake8
              --   2. activate the venv: source venv/bin/activate
              -- https://github.com/williamboman/mason.nvim/issues/179#issuecomment-1198291091
              -- https://github.com/DmytroLitvinov/awesome-flake8-extensions
              --   pandas-vet flake8-bugbear flake8-simplify flake8-pie flake8-django
              -- https://github.com/williamboman/mason.nvim/issues/392 should fix!
              -- null_ls.builtins.diagnostics.flake8.with({
              --   extra_args = { "--max-line-length", "120" },
              -- }),
              null_ls.builtins.formatting.black.with({
                -- extra_args = { "--line-length", "120" },
              }),
              null_ls.builtins.formatting.isort,
              null_ls.builtins.diagnostics.mypy.with({
                 command = '/Users/simon/.asdf/shims/mypy',
                 method = methods.internal.DIAGNOSTICS_ON_SAVE,
               }),
              -- null_ls.builtins.formatting.autopep8,

              null_ls.builtins.formatting.fixjson,
              null_ls.builtins.formatting.stylua,

              null_ls.builtins.formatting.goimports,
              null_ls.builtins.formatting.jq,

              -- null_ls.builtins.diagnostics.eslint,
              -- null_ls.builtins.formatting.eslint,

              -- null_ls.builtins.formatting.eslint_d,
              -- null_ls.builtins.diagonistics.eslint_d,
              -- null_ls.builtins.code_actions.xo -- Try xo an eslint wrapper if eslint not working?

              null_ls.builtins.diagnostics.hadolint, -- Dockerfiles
              null_ls.builtins.diagnostics.jsonlint,
              null_ls.builtins.diagnostics.shellcheck,

              null_ls.builtins.code_actions.gitsigns,
              null_ls.builtins.code_actions.refactoring,
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
  use {
    "ThePrimeagen/refactoring.nvim",
    requires = {
      {"nvim-lua/plenary.nvim"},
      {"nvim-treesitter/nvim-treesitter"}
    }
  }

  ---- Fzf -- 
  use {
    'ibhagwan/fzf-lua', -- Nifty LSP commands, doesn't support tmux
    requires = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      actions = require "fzf-lua.actions"
      fzf = require('fzf-lua')
      fzf.register_ui_select()
      -- https://github.com/ibhagwan/nvim-lua/blob/main/lua/plugins/fzf-lua/init.lua
      fzf.setup {
        winopts = {
          height = 0.9,
          width = 0.9,
          preview = {
            default = 'bat',
            flip_columns        = 500,        -- how many columns to allow vertical split
            winopts = {                       -- builtin previewer window options
              number            = false,
              relativenumber    = false,
            },
          }
        },
        previewers = {
          builtin = {
            syntax_limit_b = 1024 * 24,
            limit_b = 1024 * 24,
          },
          bat = {
            theme = 'base16-256',
          },
        },
        fzf_opts = {
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
            ["ctrl-d"]          = { actions.buf_del, actions.resume },
          }
        }
      }

      vim.cmd [[
        map z= :lua require("fzf-lua").spell_suggest()<CR>
        map <A-j> :lua require("fzf-lua").git_status()<CR>
      ]]
    end
  }
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
  use {
    'simrat39/symbols-outline.nvim',
    keys = "\\l",
    config = function()
      require("symbols-outline").setup()
      vim.keymap.set("n", "\\l", "<cmd>SymbolsOutline<CR>")
      -- vim.cmd [[
      --   nmap \l :SymbolsOutline<CR>
      -- ]]
    end
  }

  -- Standard Vim ergonomics
  use 'norcalli/nvim-colorizer.lua'
  use 'milkypostman/vim-togglelist'

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
  use 'tpope/vim-unimpaired'
  use 'tpope/vim-repeat'
  use 'RRethy/nvim-base16'

  use 'janko-m/vim-test'
  use 'mfussenegger/nvim-dap'
  use 'benmills/vimux'
  use { 'skywind3000/asyncrun.vim', keys = "!l",
    config = function() vim.cmd [[ map !l :AsyncRun bash -lc 'ctags-build'<CR> ]] end }

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

  ---- Languages -- 
  ---- We rely on TreeSitter by default, but for some languages we may want more.
  ----
  ---- * List indentation
  ---- * Make quote syntax nice and greyed out (like a comment)
  use {'preservim/vim-markdown', ft = {'markdown'}, config = function()
    vim.cmd [[
      let g:vim_markdown_new_list_item_indent = 2
      let g:vim_markdown_folding_disabled = 1
      let g:vim_markdown_frontmatter = 1
      let g:vim_markdown_auto_insert_bullets = 1
      let g:vim_markdown_math = 1
    ]]
  end }
  use 'godlygeek/tabular'
  use 'simrat39/rust-tools.nvim'
  use 'dcharbon/vim-flatbuffers'

  use { 'vim-ruby/vim-ruby', ft = 'ruby' } -- Need it for the indent..
end)
EOF

map <C-g> :lua require('fzf-lua').live_grep()<CR>
map <C-q> :lua require('fzf-lua').commands()<CR>
" map <C-w> :FzfLua dash<CR>
map <A-/> :lua require('fzf-lua').lines()<CR>
map <Space>/ :lua require('fzf-lua').grep_cword()<CR>
map <Leader>/ :lua require('fzf-lua').grep()<CR>
map <C-t> :lua require('fzf-lua').files()<CR>
map <C-j> :lua require('fzf-lua').buffers()<CR>
map <C-l> :lua require('fzf-lua').tags()<CR>
map <A-l> :lua require('fzf-lua').btags()<CR>
map <Space>l :lua require('fzf-lua').tags({ fzf_opts = { ["--query"] = vim.fn.expand("<cword>") }})<CR>
map <Space><A-l> :lua require('fzf-lua').btags({ fzf_opts = { ["--query"] = vim.fn.expand("<cword>") }})<CR>

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

" {{{
let test#strategy = "vimux"
" map <leader>t :UltestNearest<CR>
" map <leader>T :Ultest<CR>
" map <Space>t :UltestLast<CR>
map <leader>t :TestNearest<CR>
let test#python#runner = 'pytest'
map <leader>T :TestFil<CR>
map <Space>t :TestLast<CR>
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

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menu,menuone,noselect

lua << EOF
 local cmp = require'cmp'
 
 local has_words_before = function()
   if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
   local line, col = unpack(vim.api.nvim_win_get_cursor(0))
   return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
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
     expand = function(args)
       vim.fn["vsnip#anonymous"](args.body)
     end,
   },
   completion = {
     completeopt = 'menu,menuone,noinsert'
   },
   mapping = {
     ["<Tab>"] = vim.schedule_wrap(function(fallback)
       if cmp.visible() and has_words_before() then
         cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
       else
         fallback()
       end
     end),
     ["<S-Tab>"] = cmp.mapping(function()
       if cmp.visible() then
         cmp.select_prev_item()
       elseif vim.fn["vsnip#jumpable"](-1) == 1 then
         feedkey("<Plug>(vsnip-jump-prev)", "")
       end
     end, { "i", "s" }),
     ['C-j'] = cmp.mapping(function() cmp.select_next_item() end),
     ['C-K'] = cmp.mapping(function() cmp.select_prev_item() end),
     ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
     ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
     ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
     ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
     ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
     ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
     ['<C-e>'] = cmp.mapping({
       i = cmp.mapping.abort(),
       c = cmp.mapping.close(),
     }),
     ["<CR>"] = cmp.mapping.confirm({
        -- this is the important line
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
      }),
   },
   sources = cmp.config.sources({
     { name = "copilot", group_index = 2 },
     { name = "latex_symbols", group_index = 2 },
     { name = 'nvim_lsp', group_index = 2 },
     { name = 'path', group_index = 2 },
     { name = 'vsnip', group_index = 2 },
   }, {
     { name = 'buffer' },
   })
 })
 cmp.setup.filetype('markdown', {
   sources = cmp.config.sources({
   }, {
   })
 })

require'nvim-treesitter.configs'.setup {
  ensure_installed = "all",
  ignore_install = { "phpdoc", "markdown" },
  sync_install = false,
  -- matchup = {
  --   enable = true,
  -- },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
    disable = { "markdown" },
  },
  autotag = {
    enable = true,
  },
  endwise = {
    enable = true
  },
  indent = {
    -- enable = true
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

-- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
vim.o.updatetime = 250
-- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focusable=false})]]

-- https://www.reddit.com/r/neovim/comments/uqb50c/with_native_lsp_nvimcmp_how_do_you_prevent_the/
_G.LspDiagnosticsPopupHandler = function()
  local current_cursor = vim.api.nvim_win_get_cursor(0)
  local last_popup_cursor = vim.w.lsp_diagnostics_last_cursor or {nil, nil}

  -- Show the popup diagnostics window,
  -- but only once for the current cursor location (unless moved afterwards).
  if not (current_cursor[1] == last_popup_cursor[1] and current_cursor[2] == last_popup_cursor[2]) then
    vim.w.lsp_diagnostics_last_cursor = current_cursor
    vim.diagnostic.open_float(0, {scope="cursor", focusable=false})
  end
end
vim.cmd [[
augroup LSPDiagnosticsOnHover
  autocmd!
  autocmd CursorHold *   lua _G.LspDiagnosticsPopupHandler()
augroup END
]]

-- vim.lsp.set_log_level("info")
--
function insert_line_at_cursor(text, newline)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local column = cursor[2]

  if not newline then
    vim.api.nvim_buf_set_text(0, row - 1, column, row - 1, column, {text})
  else
    vim.api.nvim_buf_set_lines(0, row, row, false, {text})
  end
end

function insert_tag_at_cursor(text, newline)
  local tag = string.match(text, "([#%a-]+)")
  insert_line_at_cursor(tag, newline)
end

function ZettelkastenSearch()
  require'fzf-lua'.fzf_live(
    "textgrep", {
        actions = require'fzf-lua'.defaults.actions.files,
        previewer = 'builtin',
        exec_empty_query = true,
        fzf_opts = {
          ["--exact"] = '',
          ["--ansi"] = '',
          ["--tac"] = '',
          ["--no-multi"] = '',
          ["--no-info"] = '',
          ["--phony"] = '',
          ['--bind'] = 'change:reload:textgrep \"{q}\"',
        }
    }
  )
end

function ZettelkastenRelatedTags()
  require'fzf-lua'.fzf_exec(
    "zk-related-tags \"" .. vim.fn.bufname("%") .. "\"", {
        actions = { ['default'] = function(selected, opts) insert_tag_at_cursor(selected[1], true) end },
        fzf_opts = { ["--exact"] = '', ["--nth"] = '2' }
    }
  )
end

function ZettelkastenTags()
  require'fzf-lua'.fzf_exec(
    "zkt-raw", {
        actions = { ['default'] = function(selected, opts) insert_tag_at_cursor(selected[1], true) end },
        fzf_opts = { ["--exact"] = '', ["--nth"] = '2' }
    }
  )
end

function CompleteZettelkastenPath()
  require'fzf-lua'.fzf_exec(
    "rg --files -t md | sed 's/^/[[/g' | sed 's/$/]]/'", {
        actions = { ['default'] = function(selected, opts) insert_line_at_cursor(selected[1], false) end },
    }
  )
end

function CompleteZettelkastenTag()
  require'fzf-lua'.fzf_exec(
    "zkt-raw", {
        actions = { ['default'] = function(selected, opts) insert_tag_at_cursor(selected[1], false) end },
        fzf_opts = {
          ["--exact"] = '',
          ["--nth"] = '2',
          ["--print-query"] = '',
          ["--multi"] = "",
        }
    }
  )
end

local a = require "plenary/async"

-- TODO: Format links as <a href> or markdown, which should be easier for GPT to understand
-- TODO: A better pop up?
GPT = function()
  local prompt_prefix = vim.fn.input("Prompt prefix: ")
  local curl = require "plenary.curl"
  local iterators = require "plenary.iterators"
  local token = vim.fn.getenv("OPENAI_TOKEN")

  line1 = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
  line2 = vim.api.nvim_buf_get_mark(0, ">")[1]

  local lines = vim.api.nvim_buf_get_lines(0, line1, line2, false)
  local selected_text = table.concat(lines, "\n")
  local prompt = selected_text

  if prompt:len() > 0 then
    prompt = prompt_prefix .. "\n\n\"\"\"" .. selected_text .. "\n\"\"\""
  end

  local body = vim.fn.json_encode({
    model = 'text-davinci-002',
    prompt = prompt,
    max_tokens = 512,
    temperature = 0.7, -- risk-taking 0 to 1
    presence_penalty = 0.5, -- penalize using existing words? -2 to 2
    frequency_penalty = 0.0, -- penalize words based on their frequency -2 to 2
    best_of = 1,
  })

  curl.post('https://api.openai.com/v1/completions', {
    accept = 'application/json',
    headers = {
      authorization = 'Bearer ' .. token,
      ["content-type"] = 'application/json',
    },
    body = body,
    -- schedule_wrap schedules the callback so it has access to the Vim APIs.
    callback = vim.schedule_wrap(function(out)
      print(out.body)
      local gpt_ans = vim.fn.json_decode(out.body).choices[1].text
      local buffer = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_open_win(buffer, true, {
        relative = 'win', width=90, height=50, row=10, col=10,
        -- border = 'rounded', style = 'minimal'
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
" Light
" https://github.com/RRethy/nvim-base16
" colorscheme base16-gruvbox-material-light-hard

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

set nohlsearch " Don't highlight search results
set diffopt=filler,vertical
if has('nvim')
  set inccommand=split " Neovim will preview search
end

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
  lua vim.api.nvim_set_keymap('i', '[[', '<cmd>lua CompleteZettelkastenPath()<cr>', {})
  lua vim.api.nvim_set_keymap('i', '#', '<cmd>lua CompleteZettelkastenTag()<cr>', {})
endfunction

command! ZKRT :lua ZettelkastenRelatedTags()
command! ZKS :lua ZettelkastenSearch()
command! ZKT :lua ZettelkastenTags()
command! -range GPT :lua GPT()

" nmap <silent> <leader>v :ChatGPTEditWithInstructions<CR>
" vmap <silent> <leader>v :<C-U>:ChatGPTEditWithInstructions<CR>
" vmap <silent> <C-j> :<C-U>:ChatGPTEditWithInstructions<CR>
"

map \d :put =strftime(\"# %Y-%m-%d\")<CR>
map \D :put =strftime(\"%Y-%m-%d\")<CR>
imap jk <esc>
map <leader>d :bd<CR>
nnoremap Y y$ " Make Y behave like other capitals
nmap L :set invnumber<CR>
nmap <leader>b :Git blame<CR>

" au BufNewFile,BufRead *.tsx set filetype=typescriptreact
" au BufNewFile,BufRead *.jsx set filetype=javascriptreact
au BufNewFile,BufRead *.ejson,*.jsonl,*.avsc set filetype=json
au BufNewFile,BufRead *.s set filetype=gas
"
autocmd BufNew,BufNewFile,BufRead /Users/simon/Documents/Zettelkasten/*.md call ZettelkastenSetup()
autocmd FileType markdown setlocal commentstring=>\ %s
autocmd FileType markdown setlocal spell
autocmd FileType markdown setlocal linebreak " wrap on words, not characters
autocmd FileType markdown highlight link mkdBlockquote Comment

lua <<EOF
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    -- Workaround to https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1131
    --
    -- We can't do this in `on_attach` since Markdown may not have an `on_attach` LSP.
    -- If we don't have this, then `gq` does nothing because as of recent Neovim versions
    -- `gq` defaults to formatting with the LSP's formatter which doesn't honour
    -- textwidth necessarily.
    if vim.bo[args.buf].filetype == 'markdown' then
      vim.bo[args.buf].formatexpr = nil
    end
  end,
})
EOF

endif
