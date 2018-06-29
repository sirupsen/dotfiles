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
alias vim='nvim'

review() {
  local default_branch=$(git rev-parse --abbrev-ref HEAD)
  local branch="${1:-$default_branch}"

  git fetch origin master $branch
  git checkout $branch
  git rebase origin/$branch

  if [[ -a "dev.yml" ]]; then
    dev up
  fi

  vim -c "let g:gitgutter_diff_base = 'origin/master'" -c ":e!" $(git diff --name-only origin/master)
}

alias ttc='tmux save-buffer -|pbcopy'
alias tfc='tmux set-buffer "$(pbpaste)"'

alias walrus="ruby -e 'loop { 0.upto(50) { |i| print \"\r\" + (\" \" * i) + \":\" + %w(€ c)[i%2] + \".\" * (50-i); sleep 0.25 } }'"

alias k=kubectl
alias kgp='k get pods'
alias kgn='k get namespaces'
alias kgpn='k get pods -o name | grep -oP "(?<=/).+$"'
alias kg='k get'
alias kl='k logs $(kpgn)'
alias klz='kgpn | fzf --preview "kubectl logs {}" --height=100%'
alias kex='k exec -it $(kgpn | fzf)'
alias kexb='kubectl exec -it $(kgpn | fzf --prompt "/bin/bash > ") -- /bin/bash'
alias kns='kubectl config set-context $(k config current-context) --namespace=$(kgn -o name | grep -oP "(?<=/).+$" | fzf --prompt "k8s namespace > ")'
alias kctx='kubectl config use-context $(kubectl config get-contexts -o=name | fzf --prompt "k8s context > ") && kns'
alias kdesc='k describe $(k get pods -o name | fzf)'

alias rlias=". ~/.bash/*alias*"
alias elias="vim ~/.bash/04_aliases.bash; rlias"
alias vimrc="vim ~/.vimrc"

cliphighlight() {
  pbpaste | highlight -O rtf --font-size 54 --font Inconsolata --style solarized-dark -W -J 80 -j 3 --src-lang $1 | pbcopy
}

reset-camera () {
  sudo killall AppleCameraAssistant
  sudo killall VDCAssistant
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
