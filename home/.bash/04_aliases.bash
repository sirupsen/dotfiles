# https://github.com/github/hub
if command -v hub > /dev/null; then
  alias git=hub
fi

# alias box="mosh pufferbox -p 60000 -- tmux new-session -A -s main"
# alias box-ssh="ssh -t pufferbox tmux new-session -A -s main"
alias box="mosh gcp1 -p 60000 -- tmux new-session -A -s main"
alias box-ssh="ssh -t gcp1 tmux new-session -A -s main"
alias spot-ssh='gcloud compute ssh --zone "us-central1-c" "gcp-spotbox1" --project "turbopuffer"'
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

alias m='mutagen'
alias t='terraform'
alias k='kubectl'
alias kctx='kubectx'
alias kg='k get'
alias kgp='k get pods'
alias kgd='k get deploy'
alias kgi='k get ingress'
alias kd='k describe'
alias kns='kubens'
k-pod() {
  k get pods | tail -n +2 | awk '{ print $1 }' | fzf
}
alias k-node="k describe \"pod/\$(k-pod)\" | rg 'Node:' | rg -o 'gke-([\w-]+)'"

alias npm-update="npm-check --skip-unused -u"

git-find-merge() {
  git rev-list "$1"..master --ancestry-path \
    | grep -f \
      <(git rev-list "$1"..master --first-parent) \
    | tail -1
}

alias default_branch="git remote show origin | sed -n '/HEAD branch/s/.*: //p'"
alias cbt="BIGTABLE_EMULATOR_HOST= cbt"
alias gcb="git rev-parse --abbrev-ref HEAD"
alias gp='git push `git_origin_or_fork` `gcb`'
alias gpl='git pull `git_origin_or_fork` `gcb`'
# alias gc='git commit --verbose --signoff'
alias gc='git commit --verbose'
alias gs='git status --short --branch'
alias gsp='git stash pop'
alias gbr='git branch --no-merged origin/master --sort=-committerdate --verbose'
alias grc='git rebase --continue'
alias gl='git log --oneline'
gco() {
  _fzf_git_each_ref --no-multi | xargs git checkout
}
# alias gb='git branch'
alias gpf='if [[ $(gcb) != "master" ]]; then git push `git_origin_or_fork` +`gcb`; else echo "Not going to force push master bud"; fi'
function gd() {
  git diff "$@" ':!*lock'
}
alias ghgd="gh pr create --web"
alias gg='git grep'
alias ggi='git grep -i'
alias ga='git add'
alias gfoa='git fetch origin'
alias gf='git fetch origin'
alias gfo='git fetch origin $(default_branch)'
alias gro='git rebase origin/$(default_branch)'
alias gfogro='gfo && gro'
alias gupd='gfogro && gpf'
alias blush="git commit --amend --reuse-message HEAD"
alias squash='git rebase -i $(git merge-base HEAD master)'
alias rebase_latest_green='gfo && git rebase $(ci_last_green_master)'
alias rlg=rebase_latest_green

alias gdfm='git diff --relative --name-only $(default_branch)'
alias gdf='git diff --relative --name-only'
alias gdfjs='gdf | rg "\.(js|ts)$"'

alias git_diff_commit='git diff-tree --no-commit-id --name-only -r HEAD'
alias gdc=git_diff_commit

review-latest-commit() {
  nvim -c "let g:gitgutter_diff_base = 'HEAD~1'" -c ":e!" "$(git_diff_commit)"
}
alias rlc='review-latest-commit'

garch() {
  local commit=$(git rev-list -n 1 --before="$1" master)
  git checkout "${commit}"
}

alias peek=clone
alias bx='bundle exec'
alias bxr='bundle exec ruby'
alias rt='bx ruby -I.:test'
alias knife='chruby 2.3 && BUNDLE_GEMFILE=~/.chef/Gemfile bundle exec knife'
alias vim=nvim
alias vi=vim
alias g='gcloud'
alias rgi="rg -i"
alias r='review'

alias ttc='tmux save-buffer -|pbcopy'
alias tfc='tmux set-buffer "$(pbpaste)"'

alias walrus="ruby -e 'loop { 0.upto(50) { |i| print \"\r\" + (\" \" * i) + \":\" + %w(€ c)[i%2] + \".\" * (50-i); sleep 0.25 } }'"
alias rlias=". ~/.bash/*alias*"
alias elias="vim ~/.bash/04_aliases.bash; rlias"
alias vimrc="vim ~/.config/nvim/init.vim"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias churl="chrome --headless --disable-gpu --dump-dom"

alias whatsmyip='curl -s https://am.i.mullvad.net/json | jq'

cliphighlight() {
  pbpaste | highlight -O rtf --font-size 54 --font Inconsolata --style solarized-dark -W -J 80 -j 3 --src-lang "$1" | pbcopy
}

refresh() {
  gcloud components update

  brew update

  brew upgrade fzf neovim bash ripgrep git universal-ctags \
    fd go curl redis ruby-install telnet tree jemalloc ruby-install \
    mysql yt-dlp curl cmake docker gdb wget coreutils \
    lua luajit luajit-openresty luarocks markdown gh hub htop reattach-to-user-namespace \
    jq sqlite htop grep graphviz entr fio aspell \
    llvm cmark chrome-cli gcc bat gopls typescript git-delta \
    imagemagick angle-grinder sgpt kubectl asdf ca-certificates \
    duckdb gnuplot gperf heroku libuv mutagen openblas terraform tree-sitter \
    xxhash xsimd 1password-cli zstd font-inconsolata-nerd-font ngrok aichat

  bun upgrade

  rustup update
  rustup update nightly
  rustup component add clippy-preview

  asdf install nodejs latest
  asdf install golang latest
  asdf install python latest
  asdf install ruby latest

  nvim --headless "+Lazy! sync" +qa
}

gsum() {
    if [ $# -eq 2 ]; then
        query="Generate git commit message using semantic versioning. Declare commit message as $1. $2. My changes: $(git diff --staged)"
    elif [ $# -eq 1 ]; then
        query="Generate git commit message using semantic versioning. Declare commit message as $1. My changes: $(git diff --staged)"
    else
        query="Generate git commit message using semantic versioning. My changes: $(git diff --staged)"
    fi
    commit_message="$(sgpt --model gpt-3.5-turbo-16k txt "$query")"
    printf "%s\n" "$commit_message"
    read -rp "Do you want to commit your changes with this commit message? [y/N] " response
    if [[ $response =~ ^[Yy]$ ]]; then
        git add . && git commit -m "$commit_message"
    else
        echo "Commit cancelled."
    fi
}

alias g3='sgpt --model gpt-3.5-turbo --temperature 0.5 --no-cache'
alias g3c='g3 --repl=temp'
alias g3code='g3 --code'

gcg() {
  msg=$(gd --staged | sgpt 'Write a short, descriptive commit message for these changes')
  git commit -e -m "$msg"
}

# ZETTELKASTEN ALIASES MOVED TO https://github.com/sirupsen/zk

pbcopyfile() {
  osascript -e 'on run argv' \
    -e 'set currentDir to do shell script "pwd"' \
    -e 'set the clipboard to (read POSIX file (POSIX path of (currentDir as text & (first item of argv) )) as JPEG picture)' \
    -e 'end run' "/$1"
}


# if it's a big project you'll want to build this yourself.
file-list-tags() {
  rg --sort path --files \
      --glob '!target' \
      --glob '!vendor' \
      --type-not html \
      --type-not css \
      --type-not xml \
      --type-not markdown \
      --type-not jsonl \
      --type-not yaml \
      --type-not json \
      --type-not diff \
      --type-not asciidoc \
      --type-not avro \
      --type-not haml \
      --type-not license \
      --type-not log \
      --type-not mk \
      --type-not pdf \
      --type-not protobuf \
      --type-not readme \
      --type-not tex \
      --type-not thrift \
      --type-not toml \
      --type-not js \
    > .file_list_tags
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
    # ctags -f tags -L .file_list_tags --extras=q --sort=yes --excmd=number
    ctags -f tags -L .file_list_tags --sort=yes \
      --langmap=TypeScript:.ts.tsx \
      --langmap=JavaScript:.js.jsx --quiet=yes 
  fi
}

man() {
  echo "use tldr or manf!"
}

tldr() {
  curl "cheat.sh/$*"
}

export MANPAGER="sh -c 'col -bx | bat -l man -p'"
manf() {
  /usr/bin/man "$@"
}

zk-uniq() {
  rg --files | rg -oP "\A\d+" | sort | uniq -c | sort
}

scratch() {
  tmux rename-window scratch
  nvim -c ":set autochdir" "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Documents/Zettelkasten/scratch.md"
}

now() {
  local sirupsencom=$(z -e sirupsen.com)
  tmux rename-window now
  nvim -c ":cd ${sirupsencom}" "${sirupsencom}/posts/now.md"
}

KIBANA_VERSION="docker.elastic.co/kibana/kibana:7.6.0"
kibana() {
  local server=$(basename "$(pwd)")
  open "http://localhost:5601/app/kibana#/dev_tools/console" &
  docker run --name kibana --rm -p 5601:5601 --env ELASTICSEARCH_HOSTS="http://$server.railgun:9200" "$KIBANA_VERSION"
}


mdr() {
  ts=$(gdate +%s%N)
  echo '<html><head>' > md.html
  echo '<link rel="stylesheet" href="https://yegor256.github.io/tacit/tacit.min.css"/>' \
    >> md.html
  echo '<style>body { background-color: #f7f7f7; } h1:first-of-type { margin-top: 16px; } img { max-width: 600px; margin-left: auto; display: block; }</style>' \
    >> md.html
  echo "<title>$@ -- Markdown</title>" >> md.html

  echo "<body><section><article>" >> md.html
  cmark --smart --unsafe "$@" >> md.html
  echo "</section></article></body>" >> md.html

  tt=$((($(gdate +%s%N) - $ts)/1000000))

  chrome-cli list tabs | rg '\- Markdown' | rg -oP "(?<=\[)(\d+)" | \
    xargs -L1 chrome-cli reload -t

  echo "Re-rendered '${@}' (${tt}ms)"
}

md() {
  open "file://$PWD/md.html"
  echo "$@" | entr bash -l -c "mdr \"${@}\""
}

chrome-refresh-on-change() {
  echo "$@" | entr chrome-cli reload
}

trim-pngs() {
  for file in *.png; do
    convert -trim "$file" "$file"
  done
}

pdfrename() {
  rg --files -t pdf --max-depth 1 . | xargs -P16 -I% -L1 bash -c 'pdftitle -p "%" -c || true'
}

zk-media-from-clipboard() {
  pbpaste > ${ZK_PATH}/media/${1}
}

stopwatch() {
  start=$(date +%s)
  while true; do
    now=$(date +%s)
    elapsed=$((now-start))
    printf "\rElapsed time: %02d:%02d:%02d" $((elapsed/3600)) $((elapsed%3600/60)) $((elapsed%60))
    sleep 1
  done
}

alias loc=scc
alias youtube-dl="yt-dlp"
alias semsearch="~/src/semsearch/judge.bash"
# alias python='python3.10'
# alias pip='python -m pip'
