" idleFingers Vim Colorsheme
" This file attempts to match the Textmate color scheme idleFingers
" (http://idlefingers.co.uk/)
"
" This file was NOT created by the maintainer of idleFingers, it just
" tries to copy the color style for MacVim usage.

" Init
set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "idleFingers"

" Allows ruby syntax highlighting for operators
" NOTE: There are some additions to the syntax/ruby.vim to allow for
"       idleFingers colorscheme to work.
"let ruby_operators=0

" GUI colors

hi Cursor               guibg=#FFFFFF
hi CursorIM             guifg=NONE guibg=#ff83fa
hi Directory            guifg=#e0ffff
hi DiffAdd              guibg=#528b8b
hi DiffChange           guibg=#8b636c
hi DiffDelete           guifg=fg guibg=#000000
hi DiffText             guibg=#6959cd
hi ErrorMsg             guifg=#D8D8D8 guibg=#ff0000
hi VertSplit            guifg=#323232 guibg=#f0e68c
hi Folded               guifg=#999999 guibg=#444444
hi FoldColumn           guifg=#000000 guibg=#bdb76b
hi SignColumn           guifg=#bdb76b guibg=#20b2aa
hi IncSearch            guifg=#000000 guibg=#D8D8D8
hi LineNr               guifg=#888888
hi MatchParen           guifg=#FFFFFF guibg=#666666
hi ModeMsg              gui=NONE
hi MoreMsg              guifg=#20b2aa
hi NonText              guifg=#D8D8D8
hi Normal               guibg=#282828 guifg=#D8D8D8
hi Question             guifg=#ff6347
hi Search               guifg=#000000 guibg=#ffd700
hi SpecialKey           guifg=#00ffff
hi StatusLine           guifg=#f0e68c guibg=#000000
hi StatusLineNC         guibg=#f0e68c guifg=#666666
hi Title                guifg=#ff6347
hi Visual               guibg=#666666
hi VisualNOS            guifg=#000000 guibg=fg
hi WarningMsg           guifg=#D8D8D8 guibg=#ff6347
hi WildMenu             guifg=#000000 guibg=#ffff00


" Colors for syntax highlighting
hi Comment              guifg=#BC9458

hi Constant             guifg=#6C99BB gui=NONE
    hi String           guifg=#A5C261
    hi Character        guifg=#6C99BB
    hi Number           guifg=#6C99BB
    hi Boolean          guifg=#6C99BB
    hi Float            guifg=#6C99BB

hi Identifier           guifg=#afeeee
    hi Function         guifg=#FFF980 gui=NONE

hi Statement            guifg=#FFC66D
    hi Conditional      guifg=#CC7833
    hi Repeat           guifg=#CC7833
    hi Label            guifg=#CC7833
    hi Operator         guifg=#CC7833
    hi Keyword          guifg=#CC7833
    hi Exception        guifg=#CC7833

hi PreProc              guifg=#CC7833
    hi Include          guifg=#CC7833
    hi Define           guifg=#CC7833 gui=NONE
    hi Macro            guifg=#CC7833
    hi PreCondit        guifg=#CC7833

hi Type                 guifg=#FFF980 gui=NONE
    hi StorageClass     guifg=#FFF980
    hi Structure        guifg=#FFF980

hi Special              guifg=#ff6347
    " Underline Character
    hi SpecialChar      gui=underline guifg=#7fffd4
    hi Tag              guifg=#ff6347
    "Statement
    hi Delimiter        guifg=#D8D8D8
    " Bold comment (in Java at least)
    hi SpecialComment   guifg=#da70d6
    hi Debug            guifg=#ff0000

hi Underlined           gui=underline

hi Ignore               guifg=bg

hi Error                guifg=#D8D8D8 guibg=#ff0000

hi Todo                 guifg=#323232 guibg=#BC9458

" Helps colorize FuzzyFileFinder
hi Pmenu                guibg=#999999 guifg=#000000
hi PmenuSel             guibg=#333333 guifg=#CCCCCC

" Ruby syntax
hi rubyConditionalExpression guifg=#D8D8D8
hi rubyMethod           guifg=#D8D8D8
hi rubyInstanceVariable guifg=#B7DFF8
hi rubyRailsMethod      guifg=#B83426
hi rubyStringDelimiter  guifg=#A5C261
hi rubyControl          guifg=#CC7833
hi rubyIdentifier       guifg=#B7DFF8
hi link rubyAccess Keyword
hi link rubyAttribute Keyword
hi link rubyBeginEnd Keyword
hi link rubyEval Keyword
hi link rubyException Keyword
hi clear rubyBracketOperator
hi link rubyInvalidVariable rubyInstanceVariable

" Rails
hi railsStringSpecial guifg=#6EA533
hi railsMethod guifg=#B83426

" ERuby syntax
hi erubyRailsMethod     guifg=#B83426
hi erubyRailsRenderMethod guifg=#B83426

" HTML syntax
hi htmlTag              guifg=#FFE5BB
hi htmlTagName          guifg=#FFC66D
hi htmlEndTag           guifg=#FFE5BB
hi htmlArg              guifg=#FFE5BB
hi Title                guifg=#D8D8D8
hi link htmlSpecialTagName htmlTagName

" CSS syntax
hi cssTagName         guifg=#FFC66D
hi cssBraces          guifg=#D8D8D8
hi cssSelectorOp      guifg=#A5C261
hi cssSelectorOp2     guifg=#A5C261
hi cssInclude         guifg=#CC7833
hi cssFunctionName    guifg=#B83426
hi cssClassName       guifg=#D8D8D8
hi cssIdentifier      guifg=#D8D8D8
hi cssComment         guifg=#EEEEEE guibg=#575757
    " Let right hand side be the same color
    hi link cssFontAttr Constant
    hi link cssCommonAttr Constant
    hi link cssFontDescriptorAttr Constant
    hi link cssColorAttr Constant
    hi link cssTextAttr Constant
    hi link cssBoxAttr Constant
    hi link cssGeneratedContentAttr Constant
    hi link cssAuralAttr Constant
    hi link cssPagingAttr Constant
    hi link cssUIAttr Constant
    hi link cssRenderAttr Constant
    hi link cssTableAttr Constant

" Javascript syntax
hi javaScriptIdentifier guifg=#6C99BB
hi javaScriptType guifg=#FFC66D
hi javaScriptValue guifg=#6C99BB
hi link javaScriptBraces Normal
hi link javaScript Normal
hi link javaScriptStatement Keyword
hi link javaScriptFunction Keyword

" NERDTree coloring
hi treeDir guifg=#FFC66D
hi treeDirSlash guifg=#FFC66D

