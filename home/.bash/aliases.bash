#! /bin/bash

# This is for smart running of tests. If .zeus.sock exists, then we run the
# tests with Zeus, otherwise, fall back to Ruby.
function rt {
  if [ -e .zeus.sock ]; then
    bundle exec zeus test $1
  elif grep -q "spring-commands-testunit" Gemfile; then
    bundle exec spring testunit $@
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

function dotfiles {
  cd ~/.dotfiles
  git pull origin master
}

if command -v hub > /dev/null; then
  alias git=hub
fi

source $HOME/.bash/z.bash

alias ls='ls -G'

alias ..='cd ..'
alias ...='cd ../..'

alias cbranch="git rev-parse --abbrev-ref HEAD"
alias gp='git push origin `cbranch`'
alias gpl='git pull origin `cbranch`'
alias gc='git commit --verbose'
alias gs='git status --short --branch'
alias gb='git branch --verbose'
alias gl='git log --oneline'
alias gco='git checkout'
alias gpf='git push --force origin `cbranch`'
alias blush="git commit --amend --reuse-message HEAD && gpf"

alias bx='bundle exec'

alias vu='vagrant up'
alias vsu='vagrant suspend'
alias vs='vagrant ssh'
alias vss='cd ~/code/vagrant && vagrant ssh'

alias ttc='tmux save-buffer -|pbcopy'
alias tfc='tmux set-buffer "$(pbpaste)"'

alias gg='git grep'

alias open-ports="sudo lsof -iTCP -sTCP:LISTEN -P"
alias walrus="while true; do ruby -e '0.upto(50) { |i| print \"\r\" + (\" \" * i) + \":\" + %w(€ c)[i%2] + \".\" * (50-i); sleep 0.25 }'; done"
