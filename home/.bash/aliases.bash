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

# Checks the health of my system
function health {
  # CD into top visited repositories with the help of bash history.
  # Check if they have commits that master doesn't.

  # Check status of all running VMs and output them.
  echo "Nothing yet!"
}

function knife-each {
  knife search -i node $1 | tail -n +3
}

function knife-each-ssh {
  knife-each $1 | xargs -I^ $3 ssh deploy@^ $2
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

# If I have a fork, prioriritize pushing to that instead of origin.
function gp() {
  if git remote | grep -iq sirupsen; then
    echo -e "\x1b[33m Pushing to remote \x1b[34msirupsen\x1b[0m"
    git push sirupsen `cbranch`
  else
    git push origin `cbranch`
  fi
}

alias gpl='git pull origin `cbranch`'
alias gc='git commit --verbose'
alias gs='git status --short --branch'
alias gb='git branch --verbose'
alias grc='git rebase --continue'
alias gl='git log --oneline'
alias gco='git checkout'
if type -t __git_complete > /dev/null; then
  __git_complete gco _git_checkout
fi
alias gpf='git push --force origin `cbranch`'
alias gd='git diff'
alias blush="git commit --amend --reuse-message HEAD"

alias bx='bundle exec'
alias bxr='bundle exec rake'

alias vu='vagrant up'
alias vsu='vagrant suspend'
alias vr='vagrant resume'
alias vs='vagrant ssh'

vss() {
  local project=$1
  if [[ -z $project ]]; then
    project="vagrant"
  fi

  z "$project"

  # Ignore error if SSH doesn't work due to the machine not being up.
  vagrant ssh 2>/dev/null || (vagrant up && vagrant ssh)
}

alias ttc='tmux save-buffer -|pbcopy'
alias tfc='tmux set-buffer "$(pbpaste)"'

alias gg='git grep'

alias open-ports="sudo lsof -iTCP -sTCP:LISTEN -P"
alias walrus="while true; do ruby -e '0.upto(50) { |i| print \"\r\" + (\" \" * i) + \":\" + %w(€ c)[i%2] + \".\" * (50-i); sleep 0.25 }'; done"
