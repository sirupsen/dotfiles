#! /bin/bash

# This is for smart running of tests. If .zeus.sock exists, then we run the
# tests with Zeus, otherwise, fall back to Ruby.
function rt {
  if [[ -S .zeus.sock ]]; then
    zeus test $1
  else
    bundle exec ruby -Itest $1
  fi
}

# Paste code via stdin to eval.in. It relies on the language auto-detecting
# feature.
function evalin {
  CODE=`cat`
  curl -s --dump-header - --data "code=$CODE&execute=true" https://eval.in/ | grep -woE "https:\/\/eval.in/[0-9]+"
}

# Checks the health of my system
function health {
  # CD into top visited repositories with the help of bash history.
  # Check if they have commits that master doesn't.

  # Check status of all running VMs and output them.
  echo "Nothing yet!"
}

if command -v brew 2> /dev/null; then
  if [[ -r $(brew --prefix)/etc/profile.d/z.sh ]]; then
    source $(brew --prefix)/etc/profile.d/z.sh
  fi
fi

if command -v hub > /dev/null; then
  alias git=hub
fi

alias ls='ls -G'

alias ..='cd ..'
alias ...='cd ../..'

alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias gc='git commit -v'
alias gs='git status -sb'
alias gb='git branch -v'
alias gl='git log --oneline'
alias gco='git checkout'

alias bx='bundle exec'
alias bxr='bundle exec rake'

alias vu='vagrant up'
alias vsu='vagrant suspend'
alias vs='vagrant ssh'

alias ttc='tmux save-buffer -|pbcopy'
alias tfc='tmux set-buffer "$(pbpaste)"'

alias gg='git grep'
