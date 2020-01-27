# https://github.com/github/hub
if command -v hub > /dev/null; then
  alias git=hub
fi

alias ..='cd ..'
alias ...='cd ../..'
alias ls="ls -G"

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
alias gsp='git stash pop'
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
alias gfogro='gfo && gro'
alias gupd='gfogro && gpf'
alias blush="git commit --amend --reuse-message HEAD"
alias squash='git rebase -i $(git merge-base HEAD master)'
alias rebase_latest_green='gfo && git rebase $(ci_last_green_master)'
alias rlg=rebase_latest_green

# Git Diff Files
gdf() {
  local default_branch=$(git rev-parse --abbrev-ref HEAD)
  local branch="${1:-$default_branch}"
  local base="${2:-master}"

  git diff --name-only origin/$base...$branch
}

# Git Diff Files Test
alias gdft='gdf | rg "test/.*_test"'

alias git_diff_commit='git diff-tree --no-commit-id --name-only -r HEAD'
alias gdc=git_diff_commit

review-latest-commit() {
  nvim -c "let g:gitgutter_diff_base = 'HEAD~1'" -c ":e!" $(git_diff_commit)
}
alias rlc='review-latest-commit'

garch() {
  local commit=$(git rev-list -n 1 --before="$1" master)
  git checkout ${commit}
}

alias bx='bundle exec'
alias rt='bx ruby -I.:test'
alias knife='chruby 2.3 && BUNDLE_GEMFILE=~/.chef/Gemfile bundle exec knife'
alias vim=nvim
alias vi=vim
alias g='gcloud'
alias rgi="rg -i"

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

refresh() {
  dev clone $1
  gfogro
  dev up
}

refreshsystem() {
  vim +PlugUpdate +qall

  brew update
  brew upgrade fzf neovim bash tmux ripgrep git ctags fd go curl wireguard-go wireguard-tools
  rustup update
}

refreshall () {
  refresh shopify
  refresh activefailover
  refresh spy
  refresh cloudplatform
  refresh cusco
  refresh nginx-routing-modules
  refresh storefront-renderer
  refresh dog
  refresh magellan

  cd ~/.chef
  gpl
  bundle
  gcloud components update

  sudo killall xhyve
}

note() {
  if [[ -z $1 ]]; then
    zk-search
  else
    local args="$@"
    nvim -c ":set autochdir" "$HOME/Documents/Zettelkasten/$(date +"%Y%m%d%H%M") $args.md"
  fi
}

zk-tags() {
  rg -o "#[\w\-_]{3,}" -t md -N --no-filename "$HOME/Documents/Zettelkasten" | rg -v "^#(notes-|import-)" | sort | uniq -c | sort
}

alias zk-tagsr='zk-tags | sort -r'

# Get the latest drawing from the Zettelkasten notebook into latest ZK note.
zk-remarkable() {
  if [[ ! $1 ]]; then
    echo 'need an argument with the note id'
  else
    rmapi geta 'Zettelkasten'
    pdftk Zettelkasten-annotations.pdf cat end output zk.pdf
    convert -density 400 -trim +repage zk.pdf -quality 100 -flatten -define profile:skip=ICC zk.png
    mv zk.png "$HOME/Documents/Zettelkasten/media/$1.png"
    echo "![](media/$1.png)"
    open "media/$1.png"
    rm Zettelkasten-annotations.pdf zk.pdf
  fi
}

zk-search() {
  cd $HOME/Documents/Zettelkasten
  ruby scripts/search.rb $@ | bat
}

zks() {
  cd $HOME/Documents/Zettelkasten
  ruby scripts/search.rb $@ -f | fzf --ansi --preview 'bat {}.md' --height 100%
}

# if it's a big project you'll want to build this yourself.
file-list-tags() {
  if [[ ! -f .file_list_tags ]]; then
    rg --sort path --files > .file_list_tags
  fi
}

cscope-build() {
  rm -f cscope*
  file-list-tags
  cscope -b -q -i .file_list_tags
}

# make this better at cargo too
ctags-build() {
  if [[ -f Gemfile.lock ]]; then
    if [[ ! -f __file_list_tags ]]; then
      rg --sort path --files -t ruby > .file_list_tags
    fi
    ripper-tags -R -L .file_list_tags -f tags --extra=q
  else
    file-list-tags
    ctags -f tags -L .file_list_tags
  fi
}

man() {
  echo "use tldr or manf!"
}

tldr() {
  curl "cheat.sh/$@"
}

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
manf() {
  /usr/bin/man $@
}

zk-uniq() {
  rg --files -t md | rg -o "\A\d+" | sort | uniq -c | sort
}
