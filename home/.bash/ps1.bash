build_ps1() {
  PS1=''

  # Put in current directory only
  PS1+='\[$RED\]\W'

  # If we have __git_ps1 installed, then put it in the prompt. We do what we can
  # from the previous two lines.
  if command -v __git_ps1 > /dev/null 2>&1; then
    PS1+='\[$YELLOW\]$(__git_ps1 " (%s)")'
  fi

  # https://github.com/jonmosco/kube-ps1
  export KUBE_PS1_SYMBOL_ENABLE=false
  export KUBE_PS1_PREFIX=''
  export KUBE_PS1_SUFFIX=''
  export KUBE_PS1_DIVIDER='/'
  export KUBE_PS1_CTX_COLOR='magenta'
  export KUBE_PS1_NS_COLOR='gray'
  if command -v kube_ps1 > /dev/null 2>&1; then
    PS1+=' \[$BLUE\]$(kube_ps1)'
  fi

  PS1+='\[${NORMAL}\]'

  if [[ $COLUMNS -lt 80 ]]; then
    PS1+="\n$ "
  else
    PS1+=' $ '
  fi
}

build_ps1
