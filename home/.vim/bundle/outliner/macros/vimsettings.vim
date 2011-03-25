" Very verbose verification of various VIM variables
e dummy.otl
redir! >vimsettings.txt
silent set
silent ver
silent set all
silent let
silent map
silent function
silent au
redir END

if has("win32")
	let $LS="dir"
	let $LSLR="dir /s"
else
	let $LS="ls -l"
	let $LSLR="ls -lR"
endif

e! vimsettings.txt
$
a
--- $VIM
.
exe expand("silent! r ! $LS $VIM")
a
--- $VIMRUNTIME
.
exe expand("silent! r ! $LS $VIMRUNTIME")
a
--- $VIM/vimrc
.
exe expand("silent! r $VIM/vimrc")
a
--- $VIM/gvimrc
.
exe expand("silent! r $VIM/gvimrc")
a
--- $HOME/.vimrc
.
exe expand("silent! r $HOME/.vimrc")
a
--- $HOME/.gvimrc
.
exe expand("silent! r $HOME/.gvimrc")
a
--- $HOME/.vim
.
exe expand("silent! r ! $LSLR $HOME/.vim")
w
q!
