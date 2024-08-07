" Common config
imap jk <esc>
let mapleader="," " Mapleader
map <leader>d :bd<CR>

map \d :put =strftime(\"# %Y-%m-%d\")<CR>
map \D :put =strftime(\"%Y-%m-%d\")<CR>
nnoremap Y y$ " Make Y behave like other capitals
nmap L :set invnumber<CR>
map cf :let @* = expand("%:t")<CR> " Yank the file name without extension
map cF :let @* = expand("%:p")<CR> " Yank the full current file pathk

if exists('g:vscode')
  " Specific to Cursor/Vscode
else
  " Neovim config, can't be shared

set notermguicolors

" TODO: Remove this Sep 2024, commenting to test it's not necessary, should be
" defaults now!
" -----------------------------------------------------------------------------
"set nocompatible " No vi compatility, this first because it resets some options
"set encoding=utf-8
"syntax enable
"filetype plugin indent on
"set hidden
"set backspace=indent,eol,start
"set history=1000
"set autoread " Update the file automatically if changed and buffer isn't modified, e.g. external linter
"set incsearch     " Search as you type
"set mouse=v " Allow copy-pasting
"set smarttab
"set signcolumn=yes " always show the gutter... to avoid flickering from LSP, etc.
"set shortmess+=c
"set nospell

filetype off
set tags=.tags,./tags,tags;
let g:python3_host_prog="/Users/simon/.asdf/shims/python"
set iskeyword+=- " <cword> then includes - as part of the word
set isfname+=32 " allow spaces in file-names, which makes gf more useful

" Allow editing crontabs http://vim.wikia.com/wiki/Editing_crontab
set backupskip=/tmp/*,/private/tmp/* "
set undodir=~/.vim/undo
set noswapfile
set nowritebackup
set nobackup
set wildignore+=.git/**,public/assets/**,log/**,tmp/**,Cellar/**,app/assets/images/**,_site/**,home/.vim/bundle/**,pkg/**,**/.gitkeep,**/.DS_Store,**/*.netrw*,node_modules/*

set t_Co=256  " 2000s plz
set textwidth=80  " Switch line at 80 characters
set scrolloff=5   " Keep some distance to the bottom"
set showmatch     " Show matching of: () [] {}
set ignorecase    " Required for smartcase to work
set smartcase     " Case sensitive when uppercase is present
set smartindent   " Be smart about indentation
set expandtab     " Tabs are spaces
set tabstop=2 " Tabs are 2 spaces
set shiftwidth=2 " Even if there are tabs, preview as 2 spaces
set nohlsearch " Don't highlight search results

set diffopt=filler,vertical
if has('nvim')
  set inccommand=split " Neovim will preview search
end

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

set statusline=
set statusline+=%f:%l:%c\ %m
set statusline+=%=

au BufNewFile,BufRead *.ejson,*.jsonl,*.avsc set filetype=json
au BufNewFile,BufRead *.s set filetype=gas
autocmd BufNew,BufNewFile,BufRead /Users/simon/Documents/Zettelkasten/*.md call ZettelkastenSetup()
autocmd FileType markdown setlocal commentstring=>\ %s
autocmd FileType markdown setlocal spell
autocmd FileType markdown setlocal linebreak " wrap on words, not characters
autocmd FileType markdown highlight link mkdBlockquote Comment

lua << EOF
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

simon_on_attach = function(client, bufnr)
   local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
   local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
   buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
   local opts = { noremap=true, silent=true }

   -- This broke in Neovim 0.7
   -- https://github.com/neovim/neovim/issues/17867 then map to C-[
   -- buf_set_keymap('n', '[[', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
   -- buf_set_keymap('n', '<C-[>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
   -- buf_set_keymap('n', '<Esc>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
   -- buf_set_keymap('n', '<C-[>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
   buf_set_keymap('n', '<C-[>', '<cmd>lua require(\'fzf-lua\').lsp_definitions({jump_to_single_result = true })<CR>', opts)
   buf_set_keymap('n', '<Esc>', '<cmd>lua require(\'fzf-lua\').lsp_definitions({jump_to_single_result = true })<CR>', opts)
   buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

   -- buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts) -- No default in Neovim 0.10
   buf_set_keymap('n', '<C-K>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
   buf_set_keymap('n', '<C-a>', '<cmd>lua require(\'fzf-lua\').lsp_code_actions()<CR>', opts)
   buf_set_keymap('v', '<C-a>', '<cmd>lua require(\'fzf-lua\').lsp_code_actions()<CR>', opts)
   buf_set_keymap('n', 'gR', "<cmd>lua require(\'fzf-lua\').lsp_finder()<CR>", opts)
   -- buf_set_keymap('n', 'gr', "<cmd>lua require(\'fzf-lua\').lsp_references()<CR>", opts)
   buf_set_keymap('n', 'gr', "<cmd>lua vim.lsp.buf.references()<CR>", opts)

   buf_set_keymap('n', 'gt', "<cmd>lua require(\'fzf-lua\').lsp_typedefs()<CR>", opts)
   buf_set_keymap('n', 'gT', "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)

   buf_set_keymap('n', 'go', "<cmd>lua require(\'fzf-lua\').lsp_outgoing_calls()<CR>", opts)
   buf_set_keymap('n', 'gi', "<cmd>lua require(\'fzf-lua\').lsp_incoming_calls()<CR>", opts)

   -- Default in Neovim 0.10 is [d, ]d, so maybe should stop using these!
   buf_set_keymap('n', '[e', '<cmd>lua vim.diagnostic.goto_prev({severity = vim.diagnostic.severity.ERROR})<CR>', opts)
   buf_set_keymap('n', ']e', '<cmd>lua vim.diagnostic.goto_next({severity = vim.diagnostic.severity.ERROR})<CR>', opts)
   buf_set_keymap('n', '[E', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
   buf_set_keymap('n', ']E', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

   buf_set_keymap('n', ',e', "<cmd>lua require(\'fzf-lua\').lsp_document_diagnostics()<CR>", opts)
   buf_set_keymap('n', ',E', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
   buf_set_keymap('n', '<space>e', '<cmd>lua require(\'fzf-lua\').lsp_workspace_diagnostics()<CR>', opts)
   buf_set_keymap('n', '<space>r', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
   buf_set_keymap('n', 'gl', "<cmd>lua require(\'fzf-lua\').lsp_document_symbols()<CR>", opts)
   buf_set_keymap('n', 'gL', "<cmd>lua require(\'fzf-lua\').lsp_live_workspace_symbols()<CR>", opts)

   buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
   buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
   buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
   buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
   buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
   buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
   buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)

    if client.supports_method("textDocument/formatting") then
       local excluded_filetypes = {
          yaml = true,
          json = true,
          markdown = true,
          python = true,
      }

      local filetype = vim.bo.filetype
      if not excluded_filetypes[filetype] then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
                    group = augroup,
                    buffer = bufnr,
                    callback = function()
                            vim.lsp.buf.format { async = false }
                    end,
            })
    end
  end

   -- vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focusable=false})]]
   -- Should be the same as this?
   vim.diagnostic.config({ virtual_text = true })

   buf_set_keymap("n", ",f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
   buf_set_keymap("v", ",f", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
end

require('lazy').setup({
  {
    "frankroeder/parrot.nvim",
    tag = "v0.3.10",
    dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim' },
    -- optionally include "rcarriga/nvim-notify" for beautiful notifications
    config = function()
    require("parrot").setup {
      providers = {
        -- pplx = {
        --   api_key = os.getenv "PERPLEXITY_API_KEY",
        -- },
        openai = {
          api_key = os.getenv "OPENAI_API_KEY",
        },
        -- anthropic = {
        --   api_key = os.getenv "ANTHROPIC_API_KEY",
        -- },
        -- mistral = {
        --   api_key = os.getenv "MISTRAL_API_KEY",
        -- },
        -- gemini = {
        --   api_key = os.getenv "GEMINI_API_KEY",
        -- },
        -- ollama = {} -- provide an empty list to make provider available
      },
    }
    end,
  },
    -- {
    -- "olimorris/codecompanion.nvim",
    --   dependencies = {
    --     "nvim-lua/plenary.nvim",
    --     "nvim-treesitter/nvim-treesitter",
    --     "nvim-telescope/telescope.nvim", -- Optional
    --     {
    --       "stevearc/dressing.nvim", -- Optional: Improves the default Neovim UI
    --       opts = {},
    --     },
    --   },
    --   config = function()
    --     require("codecompanion").setup({})
    --
    --     vim.api.nvim_set_keymap("n", "<A-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
    --     vim.api.nvim_set_keymap("v", "<A-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
    --     vim.api.nvim_set_keymap("n", "<leader>a", "<cmd>CodeCompanionToggle<cr>", { noremap = true, silent = true })
    --     vim.api.nvim_set_keymap("v", "<leader>a", "<cmd>CodeCompanionToggle<cr>", { noremap = true, silent = true })
    --     vim.api.nvim_set_keymap("v", "ga", "<cmd>CodeCompanionAdd<cr>", { noremap = true, silent = true })
    --
    --     -- Expand 'cc' into 'CodeCompanion' in the command line
    --     vim.cmd([[cab cc CodeCompanion]])
    --   end,
    --   -- commit = "4fe786c3f64b6a6ce44f54c4fb1b4b22eb3c6c9c",
    -- },
    -- {
    --   "dpayne/CodeGPT.nvim",
    --   dependencies = {
    --     'nvim-lua/plenary.nvim',
    --     'MunifTanjim/nui.nvim',
    --   },
    --   config = function()
    --     require("codegpt.config")
    --     vim.g["codegpt_global_commands_defaults"] = {
    --         model = "gpt-4o",
    --     }
    --   end,
    -- },
    {
      "supermaven-inc/supermaven-nvim",
      config = function()
        require("supermaven-nvim").setup({})
      end,
    },
    -- {
    --     "zbirenbaum/copilot.lua",
    --     event = {"VimEnter"},
    --     config = function()
    --         require("copilot").setup {
    --           server_opts_overrides = {
    --             settings = {
    --               advanced = {
    --                 listCount = 10, -- #completions for panel
    --                 inlineSuggestCount = 5, -- #completions for getCompletions
    --               }
    --             },
    --           },
    --           filetypes = {
    --           },
    --           suggestion = {
    --             auto_trigger = false,
    --             debounce = 500,
    --             keymap = {
    --               next = "<C-j>",
    --               prev = "<C-k>",
    --               accept = "<C-l>",
    --             }
    --           },
    --           panel = {
    --             enabled = true,
    --             auto_refresh = false,
    --             keymap = {
    --               jump_prev = "[[",
    --               jump_next = "]]",
    --               accept = "<CR>",
    --               refresh = "gr",
    --               open = "<C-h>"
    --             },
    --           },
    --         }
    --     end
  -- },
  -- {
    -- "zbirenbaum/copilot-cmp",
    -- config = function ()
    --   require("copilot_cmp").setup {
    --     method = "getCompletionsCycling",
    --   }
    -- end
  -- },
  -- {
    -- "michaelb/sniprun",
    -- branch = "master",
    -- build = "sh install.sh",
    -- config = function()
    --   require("sniprun").setup({ })
    -- end,
  -- },
  -- { 'hrsh7th/cmp-nvim-lsp'},
  -- { 'hrsh7th/cmp-buffer'},
  -- { 'hrsh7th/cmp-path'},
  -- { 'hrsh7th/cmp-cmdline'},
  -- { 'hrsh7th/nvim-cmp', config = function()
    --   local cmp = require("cmp")

    --   local has_words_before = function()
    --     if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
    --     local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    --     return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
    --   end

    --   local feedkey = function(key, mode)
    --     vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
    --   end

    --   cmp.setup({
    --     enabled = function()
    --       if require"cmp.config.context".in_treesitter_capture("comment")==true or require"cmp.config.context".in_syntax_group("Comment") then
    --         return false
    --       else
    --         return true
    --       end
    --     end,
    --     snippet = {
    --       expand = function(args)
    --         vim.fn["vsnip#anonymous"](args.body)
    --       end,
    --     },
    --     completion = {
    --       completeopt = 'menu,menuone,noinsert'
    --     },
    --     mapping = {
    --       ["<Tab>"] = vim.schedule_wrap(function(fallback)
    --         if cmp.visible() and has_words_before() then
    --           cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
    --         else
    --           fallback()
    --         end
    --       end),
    --       ["<S-Tab>"] = cmp.mapping(function()
    --         if cmp.visible() then
    --           cmp.select_prev_item()
    --         elseif vim.fn["vsnip#jumpable"](-1) == 1 then
    --           feedkey("<Plug>(vsnip-jump-prev)", "")
    --         end
    --       end, { "i", "s" }),
    --       ['C-j'] = cmp.mapping(function() cmp.select_next_item() end),
    --       ['C-K'] = cmp.mapping(function() cmp.select_prev_item() end),
    --       ['<Down>'] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    --       ['<Up>'] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), {'i'}),
    --       ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    --       ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    --       ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    --       ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    --       ['<C-e>'] = cmp.mapping({
    --         i = cmp.mapping.abort(),
    --         c = cmp.mapping.close(),
    --       }),
    --       ["<CR>"] = cmp.mapping.confirm({
    --          -- this is the important line
    --          behavior = cmp.ConfirmBehavior.Replace,
    --          select = false,
    --        }),
    --     },
    --     sources = cmp.config.sources({
    --       -- { name = 'cmp_ai', group_index = 2 },
    --       { name = "cody", group_index = 2 },
    --       { name = "copilot", group_index = 2 },
    --       { name = "latex_symbols", group_index = 2 },
    --       { name = 'nvim_lsp', group_index = 2 },
    --       { name = 'path', group_index = 2 },
    --       { name = 'vsnip', group_index = 2 },
    --     }, {
    --       { name = 'buffer' },
    --     })
    --   })

    --   cmp.setup.filetype('markdown', {
    --     sources = cmp.config.sources({
    --     }, {
    --     })
    --   })
    -- end
  -- },
  -- { 'hrsh7th/vim-vsnip'},
  -- { 'hrsh7th/cmp-vsnip'},
  {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      config = function()
        require'nvim-treesitter.configs'.setup {
          ensure_installed = {
            "lua",
            "rust",
            "python",
            "ruby",
            "proto",
            "perl",
            "vim",
            "php",
            "go",
            "c",
            "cpp",
            "sql",
            "javascript",
            "typescript",
            "terraform",
            "json",
            "cuda",
            "asm",
            "dockerfile",
            -- "markdown",
            "toml",
            "yaml",
            "bash",
            "html",
            "css",
            "scss",
            "tsx",
            "zig"
          },
          ignore_install = { "phpdoc", "markdown" },
          sync_install = false,
          matchup = {
            enable = true,
          },
          highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
            disable = { "markdown" },
          },
          endwise = {
            enable = true
          },
          indent = {
            enable = true
          },
          -- context_commentstring = {
          --   enable = true,
          --   config = {
          --     markdown = '> %s'
          --   }
          -- },
          -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
          textobjects = {
            select = {
              enable = true,
         
              -- Automatically jump forward to textobj, similar to targets.vim
              lookahead = true,
              keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",

                ["aa"] = "@call.outer",
                ["ia"] = "@call.inner",

                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",

                ["as"] = "@scope",
              },
              selection_modes = {
                ['@parameter.outer'] = 'v', -- charwise
                ['@function.outer'] = 'V', -- linewise
                ['@class.outer'] = '<c-v>', -- blockwise
              },
              include_surrounding_whitespace = false,
            },
            move = {
              enable = true,
              set_jumps = true, -- whether to set jumps in the jumplist
              goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = { query = "@class.outer", desc = "Next class start" },
                --
                -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queires.
                ["]o"] = "@loop.*",
                -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
                --
                -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
                -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
                ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
                ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
              },
              goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
              },
              goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
              },
              goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
              },
              -- Below will go to either the start or the end, whichever is closer.
              -- Use if you want more granular movements
              -- Make it even more gradual by adding multiple queries and regex.
              goto_next = {
                ["]d"] = "@conditional.outer",
              },
              goto_previous = {
                ["[d"] = "@conditional.outer",
              }
            }
          }
        }
      end
  },
  { 'windwp/nvim-ts-autotag', config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true, -- Auto close tags
          enable_rename = true, -- Auto rename pairs of tags
          enable_close_on_slash = false -- Auto close on trailing </
        },
        per_filetype = {
          -- ["html"] = {
          --   enable_close = false
          -- }
        }
      })
    end
  },
  'RRethy/nvim-treesitter-endwise',
  {
      'nvim-treesitter/nvim-treesitter-textobjects', -- if / af for selection body
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  { 'echasnovski/mini.indentscope', version = false, config = true },

  { 
      'nvim-treesitter/nvim-treesitter-context',
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      config = function()
        require'treesitter-context'.setup()
        vim.keymap.set("n", "[c", function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end, { silent = true })
      end
  },

  'tpope/vim-sleuth', -- Set shiftwidth automatically
  'nvim-lua/plenary.nvim', -- Utility functions
  "MunifTanjim/nui.nvim", -- UI library dependency
  'sindrets/diffview.nvim',
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local gs = require("gitsigns")
      gs.setup {
          current_line_blame = true,
          current_line_blame_opts = {
            delay = 2000,
          },
          on_attach = function(bufnr)
              local gs = package.loaded.gitsigns
              if vim.g.gitgutter_diff_base then
                -- defer to ensure it happens after setup, I think this variable when set with -C might be set after the plugin has loaded
                vim.defer_fn(function()
                  gs.change_base(vim.g.gitgutter_diff_base, true)
                end, 100)
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

              -- Our own
              map('n', '<leader>hm', function() gs.change_base('master', true) end)
              map('n', '<leader>hc', function() vim.ui.input({prompt = 'Change Git Base To: ', default = vim.g.gitgutter_diff_base}, function(input) gs.change_base(input, true); end, true) end)

              -- -- Actions
              map('n', '<leader>hs', gs.stage_hunk)
              map('n', '<leader>hr', gs.reset_hunk)
              map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
              map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
              map('n', '<leader>hS', gs.stage_buffer)
              map('n', '<leader>hu', gs.undo_stage_hunk)
              map('n', '<leader>hR', gs.reset_buffer)
              map('n', '<leader>hp', gs.preview_hunk)
              map('n', '<leader>hB', function() gs.blame_line{full=true} end)
              map('n', '<leader>hb', gs.toggle_current_line_blame)
              map('n', '<leader>hd', gs.diffthis)
              map('n', '<leader>hD', function() gs.diffthis('~') end)
              map('n', '<leader>he', gs.toggle_deleted)
              map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
              map('n', '<leader>hq', function() gs.setqflist("all") end)
              map('n', '<leader>hl', function() gs.setloclist(0) end)
          end
        }
    end
  },
  'tpope/vim-rhubarb', -- Gbrowse
  { 'tpope/vim-fugitive', config = function()
    vim.cmd [[
      set statusline+=%{FugitiveStatusline()}
    ]]
  end },

  ------------------------
  ---- Code Navigbation --
  ------------------------
  -- Lsp --
  'williamboman/mason.nvim',

  {'WhoIsSethDaniel/mason-tool-installer.nvim', config = function()
    require("mason-tool-installer").setup {
        -- :MasonToolsUpdate, slow to start
        -- Mason lspconfig only supports installing LSP tools (!?)
        run_on_start = true,
        debounce_hours = 6,
        ensure_installed = {
          'lua-language-server',
          'stylua',

          'bash-language-server',
          'shellcheck',
          'shfmt',

          'tailwindcss-language-server',

          'vim-language-server',

          'rust-analyzer',
          "cpptools", -- Rust debugger

          'dockerfile-language-server',
          'hadolint', -- Dockerfiles

          --'fixjson',
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
          -- 'eslint-lsp',
          -- 'prettier',
        }
    }
  end},
  {
    "j-hui/fidget.nvim", -- shows loading and stuff for LSP
    opts = { },
  },
  {'williamboman/mason-lspconfig.nvim', config = function()
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
            require("lspconfig")["rust_analyzer"].setup {
              on_attach = simon_on_attach,
              settings = {
                ["rust-analyzer"] = {
                  check = {
                    command = "clippy",
                    allTargets = true,
                  },
                  files = {
                    -- https://github.com/rust-lang/rust-analyzer/issues/12613
                    excludeDirs = { -- It scans these for some reason... and it's really slow
                      "node_modules",
                      "logs",
                      "tmp",
                      "**/node_modules",
                      "**/site",
                      "web",
                      "target"
                    }
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
  },
  'neovim/nvim-lspconfig',

  { 'nvimtools/none-ls.nvim', -- Create LS from shell tools
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

              -- null_ls.builtins.formatting.fixjson,
              null_ls.builtins.formatting.stylua,

              null_ls.builtins.formatting.prettier,

              null_ls.builtins.formatting.goimports,
              -- Deprecated... maybe not by the time we're back to this
              -- null_ls.builtins.formatting.jq,

              -- null_ls.builtins.diagnostics.eslint,
              -- null_ls.builtins.formatting.eslint,

              -- null_ls.builtins.formatting.eslint_d,
              -- null_ls.builtins.diagonistics.eslint_d,
              -- null_ls.builtins.code_actions.xo -- Try xo an eslint wrapper if eslint not working?

              null_ls.builtins.diagnostics.hadolint, -- Dockerfiles
              -- null_ls.builtins.diagnostics.jsonlint,
              -- null_ls.builtins.diagnostics.shellcheck,
              null_ls.builtins.code_actions.refactoring,
          }
      })
    end,
  },

  { 'kyazdani42/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup {
        default = true;
      }
    end,
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      {"nvim-lua/plenary.nvim"},
      {"nvim-treesitter/nvim-treesitter"}
    }
  },

  ---- Fzf -- 
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'kyazdani42/nvim-web-devicons' },
    config = function()
      actions = require "fzf-lua.actions"
      fzf = require('fzf-lua')
      fzf.register_ui_select()
      -- https://github.com/ibhagwan/fzf-lua?tab=readme-ov-file#default-options
      fzf.setup({"fzf-tmux",
        winopts = {
          preview = {
            horizontal = 'right:45%',
          }
        },
        previewers = {
          -- builtin = { -- Let's try to disable this now, maybe bug was fixed..?
          --   syntax_limit_b = 1024 * 24,
          --   limit_b = 1024 * 24,
          -- },
          -- bat = {
          --   theme = 'base16-256',
          -- },
        },
        fzf_opts = {
          ['--ansi']        = '',
          ['--prompt']      = '> ',
          ['--info']        = 'inline',
          ['--height']      = '100%',
          ['--layout']      = 'reverse',
          ['--cycle']       = '' -- Allow `<Up>` to go to the bottom
        },
        -- tags = {
        --   fzf_opts = { ['--nth'] = '2' },
        -- },
        -- lsp = {
        --   fzf_opts = { ['--tiebreak'] = 'short,begin' },
        -- },
        files = {
          -- Don't follow symlinks, weird behavior in JS repos.
          fd_opts = "--color=never --type f --hidden --exclude .git",
        },
        diagnostics = {
          severity_limit = "Error",
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
      })

      vim.cmd [[
        " Define a command :Gco for git_branches
        command! Gco lua require("fzf-lua").git_branches()

        map <C-t>        :lua require('fzf-lua').files()<CR>
        map <A-t>        :lua require("fzf-lua").git_status()<CR>

        map <C-j>        :lua require('fzf-lua').buffers()<CR>

        map z=           :lua require("fzf-lua").spell_suggest()<CR>
        map <Space>'     :lua require("fzf-lua").marks()<CR>

        map <C-q>        :lua require('fzf-lua').commands()<CR>

        map <C-g>        :lua require('fzf-lua').live_grep_native()<CR>
        map <Space>/     :lua require('fzf-lua').grep_cword()<CR>
        map <Leader>/    :lua require('fzf-lua').grep()<CR>

        map <C-l>        :lua require('fzf-lua').tags()<CR>
        map <A-l>        :lua require('fzf-lua').btags()<CR>
        map <Space>l     :lua require('fzf-lua').tags({ fzf_opts = { ["--query"] = vim.fn.expand("<cword>") }})<CR>
        map <Space><A-l> :lua require('fzf-lua').btags({ fzf_opts = { ["--query"] = vim.fn.expand("<cword>") }})<CR>
      ]]
    end
  },
  -- {
  --   'majutsushi/tagbar',
  --   keys = { 
  --     { "\\l", "<cmd>TagbarToggle<cr>" }
  --   },
  --   config = function()
  --     vim.cmd [[
  --       nmap \l :TagbarToggle<CR>
  --       map <C-W>[ :vsp <CR>:exec("tag ".expand("<cword>"))<CR>
  --       let g:tagbar_compact = 1
  --       let g:tagbar_indent = 1
  --       set statusline+=%{tagbar#currenttag('\ [%s]\ ','','')}
  --     ]]
  --   end
  -- },
  {
    'hedyhli/outline.nvim',
    keys = { 
      { "\\l" }
    },
    config = function()
      require("symbols-outline").setup()
      vim.keymap.set("n", "\\l", "<cmd>SymbolsOutline<CR>")
    end
  },
  -- Standard Vim ergonomics
  'norcalli/nvim-colorizer.lua',

  { 'echasnovski/mini.surround', version = false, config = true },
  -- { "tpope/vim-surround",
  --   keys = {"c", "d", "y"},
  --   config = function ()
  --     vim.cmd("nmap ds       <Plug>Dsurround")
  --     vim.cmd("nmap cs       <Plug>Csurround")
  --     vim.cmd("nmap cS       <Plug>CSurround")
  --     vim.cmd("nmap ys       <Plug>Ysurround")
  --     vim.cmd("nmap yS       <Plug>YSurround")
  --     vim.cmd("nmap yss      <Plug>Yssurround")
  --     vim.cmd("nmap ySs      <Plug>YSsurround")
  --     vim.cmd("nmap ySS      <Plug>YSsurround")
  --     vim.cmd("xmap gs       <Plug>VSurround")
  --     vim.cmd("xmap gS       <Plug>VgSurround")
  --     vim.g.surround_111 = "**\\r**"
  --     vim.cmd [[ let g:surround_111 = "**\r**" ]]
  --     vim.cmd [[ let g:surround_{char2nr('b')} = "**\r**" ]]
  --   end
  -- },
  'tpope/vim-eunuch',
  'tpope/vim-unimpaired',
  'tpope/vim-repeat',
  { 'RRethy/nvim-base16', commit = '3c6a56016cea7b892f1d5b9b5b4388c0f71985be', config = function()
     vim.cmd [[
        let base16colorspace=256
        colorscheme base16-default-dark
        " Light
        " https://github.com/RRethy/nvim-base16
        " colorscheme base16-gruvbox-material-light-hard
     ]]
   end },
  --  { 'janko-m/vim-test', config = function()
  --    vim.cmd [[
  --       let test#strategy = "vimux"
  --       let test#python#runner = 'pytest'
  --
  --       map <leader>t :TestNearest<CR>
  --       map <leader>T :TestFile<CR>
  --       map <Space>t :TestLast<CR>
  --    ]]
  --   end
  -- },
  'mfussenegger/nvim-dap',
  { 'benmills/vimux', config = function() 
      vim.cmd [[
        let g:VimuxOrientation = "h"
        let g:VimuxHeight = "40"
        let g:VimuxUseNearest = 1

        function! RepeatLastTmuxCommand()
          call VimuxRunCommand('Up')
        endfunction
        map <C-e> :call RepeatLastTmuxCommand()<CR>

        " function! RunSomethingInTmux()
        "   if &filetype ==# 'markdown'
        "     call VimuxRunCommand("mdrr '" . expand('%') . "'")
        "   end
        " endfunction
        " map <A-e> :call RunSomethingInTmux()<CR>

        " this is useful for debuggers etc
        map <Space>b :call VimuxRunCommand(bufname("%") . ":" . line("."), 0)<CR>
        map !b :call VimuxRunCommand(bufname("%") . ":" . line("."), 1)<CR>
      ]]
    end
  },
  { 'skywind3000/asyncrun.vim', keys = { { "!l" } },
    config = function()
      vim.cmd [[
        map !l :AsyncRun bash -lc 'ctags-build'<CR>
        let g:asyncrun_status = "stopped"
        augroup QuickfixStatus
        au! BufWinEnter quickfix setlocal 
          \ statusline+=%t\ [%{g:asyncrun_status}]\ %{exists('w:quickfix_title')?\ '\ '.w:quickfix_title\ :\ ''}\ %=%-15(%l,%c%V%)\ %P
        augroup END
      ]]
    end
  },
  {
    'kyazdani42/nvim-tree.lua',
    keys = { 
      { "\\t" }
    },
    dependencies = {
        'kyazdani42/nvim-web-devicons', -- optional, for file icon
    },
    config = function()
      require'nvim-tree'.setup {}
      vim.cmd [[ map \t :NvimTreeToggle<CR> ]]
    end
  },

  ---- We rely on TreeSitter by default, but for some languages we may want more.
  ----
  ---- * List indentation
  ---- * Make quote syntax nice and greyed out (like a comment)
  {'preservim/vim-markdown', ft = {'markdown'},
    config = function()
      vim.cmd [[
        let g:vim_markdown_new_list_item_indent = 2
        let g:vim_markdown_folding_disabled = 1
        let g:vim_markdown_frontmatter = 1
        let g:vim_markdown_auto_insert_bullets = 1
        let g:vim_markdown_math = 1
      ]]
    end
  },
  'godlygeek/tabular',
   { 'vim-ruby/vim-ruby', ft = { 'ruby', 'eruby' } },
})

-- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
vim.o.updatetime = 250

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

vim.cmd [[
augroup LSPDiagnosticsOnHover
  autocmd!
  autocmd CursorHold *   lua _G.LspDiagnosticsPopupHandler()
augroup END
]]

vim.lsp.set_log_level("info")
EOF

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

endif " retain

" Inline small plugins like this
" https://github.com/milkypostman/vim-togglelist/blob/master/plugin/togglelist.vim
function! s:GetBufferList() 
  redir =>buflist 
  silent! ls! 
  redir END 
  return buflist 
endfunction

function! ToggleLocationList()
  let curbufnr = winbufnr(0)
  for bufnum in map(filter(split(s:GetBufferList(), '\n'), 'v:val =~ "Location List"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
    if curbufnr == bufnum
      lclose
      return
    endif
  endfor

  let winnr = winnr()
  let prevwinnr = winnr("#")

  let nextbufnr = winbufnr(winnr + 1)
  try
    lopen
  catch /E776/
      echohl ErrorMsg 
      echo "Location List is Empty."
      echohl None
      return
  endtry
  if winbufnr(0) == nextbufnr
    lclose
    if prevwinnr > winnr
      let prevwinnr-=1
    endif
  else
    if prevwinnr > winnr
      let prevwinnr+=1
    endif
  endif
  " restore previous window
  exec prevwinnr."wincmd w"
  exec winnr."wincmd w"
endfunction

function! ToggleQuickfixList()
  for bufnum in map(filter(split(s:GetBufferList(), '\n'), 'v:val =~ "Quickfix List"'), 'str2nr(matchstr(v:val, "\\d\\+"))') 
    if bufwinnr(bufnum) != -1
      cclose
      return
    endif
  endfor
  let winnr = winnr()
  if exists("g:toggle_list_copen_command")
    exec(g:toggle_list_copen_command)
  else
    copen
  endif
  if winnr() != winnr
    wincmd p
  endif
endfunction

if !exists("g:toggle_list_no_mappings")
    nmap <script> <silent> <leader>l :call ToggleLocationList()<CR>
    nmap <script> <silent> <leader>q :call ToggleQuickfixList()<CR>
endif
