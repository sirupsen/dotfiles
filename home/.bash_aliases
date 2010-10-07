#! /bin/bash

# Platform information
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='darwin'
fi

# Linux and Darwin/BSD have different ways to get color
# in `ls`
if [[ $platform == 'linux' ]]; then
   alias ls='ls --color=auto'
elif [[ $platform == 'darwin' ]]; then
   alias ls='ls -G'
fi

alias ll='ls -l'
alias la='ls -A'
alias l='ls'

alias c='cd'
alias !='sudo'

# Ruby aliases
alias gems='gem list'
alias r='ruby'

#
# Git
#
alias git='hub'

# Commiting
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gc='git commit -v'
alias gca='git commit -av'
alias gs='git status -sb'
alias gb='git branch -v'
alias glog='git log --oneline'
alias gm='git merge --no-ff'

function gco {
  if [ -z "$1" ]; then
    git checkout master
  else
    git checkout $1
  fi
}

#
# Rails
#

alias sc='./script/console'
alias sg='./script/generate'
alias ss='./script/server'
alias sp='./script/server -e production'
alias rk='rake test'
alias rkp='rake parallel:test'
alias ta='autotest -rails'

# General
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../../'

# Work
alias work='cd ~/Code/Work/'
alias ~='cd ~'

# Handy 
alias clipboard="xclip -selection c"
alias svim="sudo vim"
