call pathogen#infect() " Setup Bundle Support

" BASIC
set nocompatible " No vi compatility
let mapleader="," " Mapleader
filetype plugin indent on " Automatically change file types
set encoding=utf-8
set history=1000 " Keep (a lot) more history

" BACKUP
set noswapfile 
set nobackup
" Allow editing crontabs http://vim.wikia.com/wiki/Editing_crontab
set backupskip=/tmp/*,/private/tmp/* "
set undodir=~/.vim/undo

" PRETTY COLORS
syntax enable
colorscheme solarized
set background=dark " Set dark solarized theme
set t_Co=256 " 256 colors

set textwidth=80 " Switch line at 80 characters
set scrolloff=5 " Keep some distance to the bottom"
set sidescrolloff=5

set showmatch " Show matching of: () [] {}
set showlol

" SEARCHING
set smartcase " Case sensitive when uppercase is present
set incsearch " Search as you type

" FORMATTING
set autoindent " Indent at the same level as previous line
set smartindent
set smarttab
set expandtab " Tabs are spaces

set tabstop=2 " Tabs are 2 spaces
set backspace=2 " Backspace back 2 spaces
set shiftwidth=2 " Even if there are tabs, preview as 2 spaces

" KEY MAPPING
map <C-J> <C-W>j
map <C-K> <C-W>k
map <C-L> <C-W>l
map <C-H> <C-W>h

imap jk <esc>
map <leader>d :bd<CR>
map <leader>cd :cd %:p:h<CR>

" PLUGINS

" Ctrlp
let g:ctrlp_map = '<c-t>'
let g:ctrlp_working_path_mode = 2 " Be smart about working dir
  
" Fugitive
map <leader>gs :Gstatus<CR>
map <leader>gc :Gcommit<CR>

" Tabular {
map <Leader>t= :Tab /=<CR>
map <Leader>t= :Tab /=<CR>
map <Leader>t> :Tab /=><CR>
map <Leader>t> :Tab /=><CR>
map <Leader>t: :Tab /:\zs<CR>
map <Leader>t: :Tab /:\zs<CR>

map <C-E> :call Execute()<CR>
map <C-S> :call SpecialExecute()<CR>

function! Execute()
  exec ":w"

  let informatics = 0
  let runner = 0
  let compile_command = 0

  if match(expand('%:p'), 'informatics') != -1
    let informatics = 1
  endif

  if match(expand('%'), '\.rb') != -1
    if !informatics
      if match(expand('%'), '_test') != -1
        if filereadable("./Gemfile")
          exec "!bundle exec ruby -Itest % --use-color=true"
        else
          exec "!ruby -Itest % --use-color=true"
        end
      else
        exec "!ruby %"
      end
    else
      let runner = "ruby " . @%
    end
  elseif match(expand('%'), '\.clj') != -1
    if !informatics
      exec "!clj %"
    else
      let runner = "clj " . @%
    end
  elseif match(expand('%'), '\.cpp') != -1
    let executeable = substitute(@%, ".cpp", "", "")
    let compile_command = "clang++ % -o " . executeable . " -O2"
    let runner = "./" . executeable

    if !informatics
      exec "!" . compile_command . " && " . runner
    endif
  elseif match(expand('%'), '\.vimrc') != -1
    exec "source $MYVIMRC"
  endif


  if informatics
    if compile_command != -1
      exec "!" . compile_command . " && informatics_tester '" . runner . "'"
    else
      exec "!informatics_tester '" . runner . "'"
    end
  endif
endfunction

function! SpecialExecute()
  if match(expand('%'), '_test.rb') != -1
    exec "!rake test"
  elseif match(expand('%'), '\.cpp') != -1
    let executeable = substitute(@%, ".cpp", "", "")
    let compile_command = "clang++ % -o " . executeable . " -O2"
    let runner = "./" . executeable

    exec "!" . compile_command . " && " . runner
  endif
endfunction

" K and J behaves as expected for long lines.
nmap k gk
nmap j gj
vmap k gk
vmap k gk

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
