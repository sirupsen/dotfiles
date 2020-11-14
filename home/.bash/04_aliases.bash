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
  brew upgrade fzf neovim bash tmux ripgrep git universal-ctags \
    fd go curl redis ruby-install telnet tree jemalloc ruby-install \
    mysql youtube-dl curl cmake docker gdb wget universal-ctags \
    lua luajit markdown gh hub htop reattach-to-user-namespace \
    jq sqlite kubernetes-cli wrk hugo htop toxiproxy grep graphviz \
    entr fio aspell llvm cmark

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


# ZETTELKASTEN ALIASES MOVED TO https://github.com/sirupsen/zk

pbcopyfile() {
  osascript -e 'on run argv' \
    -e 'set currentDir to do shell script "pwd"' \
    -e 'set the clipboard to (read POSIX file (POSIX path of (currentDir as text & (first item of argv) )) as JPEG picture)' \
    -e 'end run' "/$1"
}


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

remarkable() {
  rmapi geta 'Quick sheets'
  pdftk Quick\ sheets-annotations.pdf cat end output quick.pdf
  convert -density 400 -trim +repage quick.pdf -quality 100 -flatten -define profile:skip=ICC quick.png
}

# if it's a big project you'll want to build this yourself.
file-list-tags() {
  rg --sort path --files --glob '!target' --glob '!vendor' > .file_list_tags
}

cscope-build() {
  rm -f cscope*
  file-list-tags
  cscope -b -q -i .file_list_tags
}

# make this better at cargo too
ctags-build() {
  if [[ -f Gemfile.lock ]] && [[ $(command -v ripper-tags) ]]; then
    rg --sort path --files -t ruby > .file_list_tags
    ripper-tags -R -L .file_list_tags -f tags --extra=q
  else
    file-list-tags
    ctags -f tags -L .file_list_tags --extras=q --sort=yes
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
  rg --files | rg -oP "\A\d+" | sort | uniq -c | sort
}

scratch() {
  ln -fs "$HOME/Documents/Zettelkasten/scratch.md" ~/scratch.md
  tmux rename-window scratch
  nvim -c ":set autochdir" "$HOME/Documents/Zettelkasten/scratch.md"
}

mdr() {
  ts=$(gdate +%s%N)
  echo "<section><article>" > md.html
  echo "<b><h3>$@</h3></b>" >> md.html
  cmark --smart --unsafe "$@" >> md.html
  echo "</section></article>" >> md.html

  echo '<link rel="stylesheet" href="https://yegor256.github.io/tacit/tacit.min.css"/>' \
    >> md.html
  echo '<style>img { max-width: 600px; margin-left: auto; display: block; }</style>' \
    >> md.html

  tt=$((($(gdate +%s%N) - $ts)/1000000))
  echo "Re-rendered (${tt}ms)"

  # Brings the application to the foreground :(
  # cat <<'EOF' | osascript
# tell application "Firefox"
  # activate
  # tell application "System Events" to keystroke "r" using command down
# end tell
# EOF
}

alias firefox='/Applications/Firefox.app/Contents/MacOS/firefox'

mdrr() {
  mdr "$@"
  open "file://$PWD/md.html"
  echo "$@" | entr bash -l -c "mdr '$@'"
}

pdfrename() {
  rg --files -t pdf --max-depth 1 . | xargs -P16 -I% -L1 bash -c 'pdftitle -p "%" -c || true'
}

zk-media-from-clipboard() {
  pbpaste > $ZK_PATH/media/$1
}
