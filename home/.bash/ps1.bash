build_ps1() {
  PS1=''
  [ $(uname) == 'Linux' ] && PS1+='\[$BLUE\]\h:'
  PS1+='\[$RED\]\W'
  PS1+='\[${NORMAL}\]'
  PS1+=' $ '
}

build_ps1
