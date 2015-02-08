#! /bin/bash

# https://github.com/github/hub
if command -v hub > /dev/null; then
  alias git=hub
fi

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

git-find-merge() {
  git rev-list $1..master --ancestry-path \
    | grep -f \
      <(git rev-list $1..master --first-parent) \
    | tail -1
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
alias gpf='if [[ $(cbranch) != "master" ]]; then git push `git_origin_or_fork` +`cbranch`; else echo "Not going to force push master bud"; fi'
alias gd='git diff'
alias gg='git grep'
alias gupdate='git fetch origin && git rebase origin/master && gpf'
alias blush="git commit --amend --reuse-message HEAD"

alias bx='bundle exec'
alias rt='bx ruby -Itest'
alias vs='vagrant ssh'

vss() {
  cd ~/src/vagrant
  # Ignore error if SSH doesn't work due to the machine not being up.
  vagrant ssh 2>/dev/null || (vagrant up && vagrant ssh)
}

alias ttc='tmux save-buffer -|pbcopy'
alias tfc='tmux set-buffer "$(pbpaste)"'
