#! /bin/bash

# This is for smart running of tests. If .zeus.sock exists, then we run the
# tests with Zeus, otherwise, fall back to Ruby.
function rt {
  if [ -e .zeus.sock ]; then
    bundle exec zeus test $1
  # elif grep -q "spring-commands-testunit" Gemfile; then
  #   bundle exec spring testunit $@
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

function knife-each {
  knife search -i node $1 | tail -n +3
}

function knife-each-ssh {
  knife-each $1 | xargs -I^ $3 ssh simon@^ "hostname && $2"
}

function dotfiles {
  cd ~/.dotfiles
  git pull origin master
}

if command -v hub > /dev/null; then
  alias git=hub
fi

source $HOME/.bash/z.bash

# Enable fancy coloring on GNU ls
if ls --version | grep -q GNU; then
  eval `dircolors ~/.dir_colors`
  alias ls='ls --color=auto'
else
  alias ls='ls -G'
fi

alias ..='cd ..'
alias ...='cd ../..'

alias cbranch="git rev-parse --abbrev-ref HEAD"

git_origin_or_fork() {
  if git remote 2>/dev/null | grep -iq sirupsen; then
    echo "sirupsen"
  else
    echo "origin"
  fi
}

alias gp='git push `git_origin_or_fork` `cbranch`'
alias gpl='git pull `git_origin_or_fork` `cbranch`'
alias gc='git commit --verbose'
alias gs='git status --short --branch'
alias gb='git branch --verbose'
alias grc='git rebase --continue'
alias gl='git log --oneline'
alias gco='git checkout'
if type -t __git_complete > /dev/null; then
  __git_complete gco _git_checkout
fi
alias gpf='git push `git_origin_or_fork` +`cbranch`'
alias gd='git diff'
alias gupdate='git fetch origin && git rebase origin/master && gpf'
alias blush="git commit --amend --reuse-message HEAD"

alias bx='bundle exec'
alias bxr='bundle exec rake'

alias vu='vagrant up'
alias vsu='vagrant suspend'
alias vr='vagrant resume'
alias vs='vagrant ssh'

vss() {
  cd ~/src/vagrant
  # Ignore error if SSH doesn't work due to the machine not being up.
  vagrant ssh 2>/dev/null || (vagrant up && vagrant ssh)
}

alias ttc='tmux save-buffer -|pbcopy'
alias tfc='tmux set-buffer "$(pbpaste)"'

alias gg='git grep'

alias open-ports="sudo lsof -iTCP -sTCP:LISTEN -P"
alias walrus="ruby -e 'loop { 0.upto(50) { |i| print \"\r\" + (\" \" * i) + \":\" + %w(€ c)[i%2] + \".\" * (50-i); sleep 0.25 } }'"

green() {
  walrus & >/dev/null 2>&1
  WALRUS_PID=$!

  while true; do
    git ci-status > /dev/null \
      && say "$(basename `pwd`) green" \
      && kill -SIGKILL $WALRUS_PID > /dev/null 2>&1 \
      && return
    sleep 0.1
  done
}
