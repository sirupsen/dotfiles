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

# Remove to thrash
#alias rm='mv --target-directory=$HOME/.Trash'

#
# Git
#
#alias git='hub'

# Commiting
alias gcam='git commit -am'
alias gcav='git commit -av'
alias gcv='git commit -v'
alias gca='git commit -a'

alias gc='git clone'

alias gp='git push'
alias gpo='git push origin'
alias gpom='git push origin master'

alias gl='git pull'

alias gb='git branch'

alias gco='git checkout'
alias gcb='git checkout -b'

alias gs='git status -s'
alias gd='git diff'

alias glog='git log --oneline'

# General
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../../'

# Handy 
alias clipboard="xclip -selection c"
alias svim="sudo vim"
