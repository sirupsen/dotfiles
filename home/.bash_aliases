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

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../../'

#
# Git
#
#alias git='hub'

# Commiting
alias gp='git push'
complete -o default -o nospace -F _git_push gp

alias gpl='git pull'
complete -o default -o nospace -F _git_pull gpl

alias gd='git diff'
complete -o default -o nospace -F _git_diff gd

alias gc='git commit -v'
alias gca='git commit -av'
alias gcp='git commit -p'

alias gs='git status -sb'

alias gb='git branch -v'
complete -o default -o nospace -F _git_branch gb

alias ggraph='git log --graph --pretty=oneline --abbrev-commit'

alias glog='git log --oneline'
complete -o default -o nospace -F _git_log glog

alias gm='git merge'
complete -o default -o nospace -F _git_merge gm

alias gco='git checkout'
complete -o default -o nospace -F _git_checkout gco

#
# Mercurial
#

alias hgc='hg commit -m'
alias hgpl='hg pull'
alias hgp='hg push'
alias hgd='hg diff'
alias hgs='hg status'
alias hgu='hg update'
alias hgbr='hg branches'
alias hgb='hg branch'
alias hgl='hg slog | head -n 10'

# 
# Ruby
#

alias gems='gem list'

#
# Rails
#

alias sc='./script/console'
alias sg='./script/generate'
alias ss='./script/server'
alias hydra='env RUBYLIB=test RAILS_ENV=test rake hydra'
