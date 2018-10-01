# https://github.com/github/hub
if command -v hub > /dev/null; then
  alias git=hub
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ls="ls --color=always"

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

alias gcb="git rev-parse --abbrev-ref HEAD"
alias gp='git push `git_origin_or_fork` `gcb`'
alias gpl='git pull `git_origin_or_fork` `gcb`'
alias gc='git commit --verbose'
alias gs='git status --short --branch'
alias gbr='git branch --no-merged origin/master --sort=-committerdate | head -n 10'
alias grc='git rebase --continue'
alias gl='git log --oneline'
alias gco='git checkout'
alias gb='git branch'
alias gpf='if [[ $(gcb) != "master" ]]; then git push `git_origin_or_fork` +`gcb`; else echo "Not going to force push master bud"; fi'
alias gd='git diff'
alias gg='git grep'
alias ggi='git grep -i'
alias ga='git add'
alias gfo='git fetch origin master'
alias gro='git rebase origin/master'
alias gfogro='gfo && gro && dev up'
alias gupd='gfo && gro && gpf && dev up'
alias blush="git commit --amend --reuse-message HEAD"
alias squash='squash=`git rebase -i $(git merge-base HEAD master)`'

garch() {
  local commit=$(git rev-list -n 1 --before="$1" master)
  git checkout ${commit}
}

alias bx='bundle exec'
alias rt='bx ruby -I.:test'
alias knife='chruby 2.3 && BUNDLE_GEMFILE=~/.chef/Gemfile bundle exec knife'

vim() {
  if [[ -z $@ ]]; then
    nvim +FZF
  else
    nvim $@
  fi
}
alias vi=vim

# This will open the diff to master (the same diff as in a pull request). If you
# pass a second argument, it'll use that branch as a base instead.
review() {
  local default_branch=$(git rev-parse --abbrev-ref HEAD)
  local branch="${1:-$default_branch}"
  local base="${2:-master}"

  git fetch origin $base $branch

  # This typically fails if you have stashed changes.
  if ! git checkout $branch; then
    return 1
  fi

  nvim -c "let g:gitgutter_diff_base = 'origin/$base'" -c ":e!" $(git diff --name-only origin/$base...$branch)
}

# This will run "dev" (internal shopify tool that pulls all dependencies) to
# ensure that I can easily run test. This is typically my default command to
# run! Might extend this with generic Ruby, Docker, and Vagrant support later..
review-test() {
  local default_branch=$(git rev-parse --abbrev-ref HEAD)
  local branch="${1:-$default_branch}"
  local base="${2:-master}"

  if [[ -a "dev.yml" ]]; then
    dev up
  fi

  review $branch $base
}

alias ttc='tmux save-buffer -|pbcopy'
alias tfc='tmux set-buffer "$(pbpaste)"'

alias walrus="ruby -e 'loop { 0.upto(50) { |i| print \"\r\" + (\" \" * i) + \":\" + %w(€ c)[i%2] + \".\" * (50-i); sleep 0.25 } }'"
alias rlias=". ~/.bash/*alias*"
alias elias="vim ~/.bash/04_aliases.bash; rlias"
alias vimrc="vim ~/.vimrc"

alias whatsmyip='curl -s https://am.i.mullvad.net/json | jq'

cliphighlight() {
  pbpaste | highlight -O rtf --font-size 54 --font Inconsolata --style solarized-dark -W -J 80 -j 3 --src-lang $1 | pbcopy
}

reset-camera () {
  sudo killall AppleCameraAssistant
  sudo killall VDCAssistant
}

brew() {
  local brew_user=$(stat -c "%U" /usr/local/Homebrew/)
  if [[ ${brew_user} == $(whoami) ]]; then
    /usr/local/bin/brew $@
  else
    sudo -u $brew_user -- /usr/local/bin/brew $@
  fi
}

fresh() {
  dev cd $1
  gfogro
}

freshall () {
  fresh shopify
  fresh activefailover
  fresh spy
  fresh cloudplatform
  fresh cusco
  fresh nginx-routing-modules

  cd ~/.chef
  gpl
  bundle

  vim +PlugUpdate +qall

  sudo killall xhyve
}
