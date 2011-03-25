set guioptions+=M
set guifont=Lucida_Console:h11:cANSI
set lines=60
set columns=90
set listchars=tab:»·,trail:·
set showbreak=»

let otl_bold_headers=0

" COLOR SCHEMES: pick one
"
" Morning: gray background
" colorscheme morning
" hi Normal guibg=#e8e8e8
" hi Folded guibg=#e0e0e0

syn on

colorscheme default
hi Normal guifg=Sys_WindowText guibg=Sys_Window
" hi Folded guifg=Sys_WindowText guibg=#f0f0f0
hi Folded guibg=#f0f0f0
