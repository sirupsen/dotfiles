set nocompatible
filetype plugin on

if has("eval")
  let cpo_save=&cpo
endif
set cpo=B

set background=light
set mouse=a
set linebreak
set scrolloff=2
set backspace=eol,indent,start
set smartcase
set ignorecase
syn on
set ffs=dos,unix,mac

" TVO defaults:
let otl_install_menu=1
let no_otl_maps=0
let no_otl_insert_maps=0

" overrides:
let otl_bold_headers=0
let otl_use_thlnk=0

let maplocalleader = ","

if has("eval")
  let &cpo=cpo_save
  unlet cpo_save
endif
