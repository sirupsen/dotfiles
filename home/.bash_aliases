#! /bin/bash

# Linux and Darwin/BSD have different ways to get color
# in `ls`
if [[ $platform == 'linux' ]]; then
   alias ls='ls --color=auto'
elif [[ $platform == 'darwin' ]]; then
   alias ls='ls -G'
fi

# General aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls'

alias c='clear'
alias !='sudo'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../../'

alias svim="sudo vim"
alias ~='cd ~'

#
# Git
#
alias git='hub'

# Commiting
alias gp='git push'
complete -o default -o nospace -F _git_push gp

alias gpl='git pull'
complete -o default -o nospace -F _git_pull gpl

alias gd='git diff | vim -R -'

if [[ $platform == 'darwin' ]]; then
   alias gd='git diff'
fi
complete -o default -o nospace -F _git_diff gd

alias gc='git commit -v'
alias gca='git commit -av'

alias gs='git status -sb'

alias gb='git branch -v'
complete -o default -o nospace -F _git_branch gb

alias ggraph='git log --graph --pretty=oneline --abbrev-commit'

alias glog='git log --oneline'
complete -o default -o nospace -F _git_log glog

alias gm='git merge'
complete -o default -o nospace -F _git_merge gm

function gco {
  if [ -z "$1" ]; then
    git checkout master
  else
    git checkout $1
  fi
}

complete -o default -o nospace -F _git_checkout gco

# 
# Ruby
#

alias gems='gem list'
alias r='ruby'
alias rw='ruby -w'

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

alias server='178.63.193.163'
