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
alias gbr='git branch --no-merged origin/master --sort=-committerdate | head -n 10'
alias grc='git rebase --continue'
alias gl='git log --oneline'
alias gco='git checkout'
if type -t __git_complete > /dev/null; then
  __git_complete gco _git_checkout
fi
alias gpf='if [[ $(cbranch) != "master" ]]; then git push `git_origin_or_fork` +`cbranch`; else echo "Not going to force push master bud"; fi'
alias gd='git diff'
alias gg='git grep'
alias ga='git add'
alias gfo='git fetch origin master'
alias gro='git rebase origin/master'
alias gfogro='gfo && gro && dev up'
alias gupd='gfo && gro && gpf && dev up'
alias blush="git commit --amend --reuse-message HEAD"
alias squash='squash=`git rebase -i $(git merge-base HEAD master)`'

alias bx='bundle exec'
alias rt='bx ruby -I.:test'
alias vs='vagrant ssh'
alias knife='chruby 2.3 && BUNDLE_GEMFILE=~/.chef/Gemfile bundle exec knife'
alias vim='nvim'

review() {
  git fetch origin $1
  git checkout $1
  git rebase origin/$1
  if [[ -a "dev.yml" ]]; then
    dev up
  fi

  # local pr=$(chrome-cli info | grep -Po "(?<=pull\/)[0-9]+")
  # local repo=$(chrome-cli info | grep -Po "(?<=github.com\/)\w+\/\w+")

  # if [[ -z $pr || -z $repo ]]; then
  #   echo "is your open tab a github PR?"
  #   return 1
  # fi

  # cd "${HOME}/src/github.com/${repo}"
  # gh pr ${pr} --fetch
  # dev up
}

alias ttc='tmux save-buffer -|pbcopy'
alias tfc='tmux set-buffer "$(pbpaste)"'

alias walrus="ruby -e 'loop { 0.upto(50) { |i| print \"\r\" + (\" \" * i) + \":\" + %w(€ c)[i%2] + \".\" * (50-i); sleep 0.25 } }'"
alias k=kubectl

alias ralias=". ~/.bash/*alias*"
alias ealias="vim ~/.bash/04_aliases.bash && ralias"
