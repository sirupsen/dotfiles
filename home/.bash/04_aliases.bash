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

  vim +PlugUpdate +qall
  gcloud components update

  brew update
  brew upgrade fzf neovim bash tmux ripgrep git ctags fd go curl wireguard-go wireguard-tools
  rustup update

  sudo killall xhyve
}

# Zettelkasten shortcuts.
# DYNALIST_API_TOKEN is defined in ~/.bash/secrets.bash (git ignored)
zk-raw() {
  curl -s -XPOST -d "{\"token\": \"$DYNALIST_API_TOKEN\", \"file_id\": \"EY4Pzn1iyxegUbLJaRJpkdjg\"}'" \
    https://dynalist.io/api/v1/doc/read
}

zk() {
 zk-raw | jq -r '.nodes | .[] | .content, .note, ""'
}


zk-ratings() {
  zk | rg "#pw" | rg "#u(\d+).+#u(\d+)" -o -r '$1 -> $2'
}

zk-unreviewed() {
  zk-raw | jq ".nodes | .[] | select(.note | test(\"&review-\") | not) "
}

zk-count() {
  zk-raw | jq ".nodes | length"
}

zk-check-dups() {
  zk | rg "^\d+\. " -o | sort | uniq -cd
}

zk-check-review-format() {
  zk-raw | jq -r ".nodes | .[] .note" | rg -o "&review-\d+" | rg -v "\d{10}"
}

zk-check-title-format() {
  zk-raw | jq -r ".nodes | .[] | .content" | tail -n +2 | rg -v "\d{10}+\. [\w\s[[:punct:]]]+ \(.+\)"
}

zk-check-date-format() {
  zk | rg -o "\d{10}" | \
  rb -l "n = Time.strptime(self, '%y%m%d%H%M'); \
    (n < Time.strptime('2016', '%Y') || n > Time.strptime('2020', '%y')) && self" | \
  rg -v false
}

zk-tags() {
  zk | rg -o "#[\w\-_]+" | rg -v "#(u|r)\d+" | rg -v "#p(w|i)" | sort | uniq -c | sort -r
}

zk-check-format() {
  zk-check-review-format
  zk-check-title-format
  zk-check-date-format
}

zk-check-length() {
  zk-raw | rb '\
    from_json[:nodes][1..-1].select { |n|
      n[:word_length] = n[:note].split("\n").reject { |l|
        l =~ /\A(!|#|\\#|&|\[|>)/ || l.empty?
      }.join.split.size
      n[:word_length] > 80
    }.each { |n|
      puts "VIOLATES LENGTH... #{n[:word_length]}/80"
      puts n[:content]
      puts n[:note]
      puts
    }; nil
  '
}

# TODO:
# - if using keywords, check that some don't have too many, or too few?
# - check for sparse # tags?
zk-check() {
  zk-check-dups
  zk-check-format
  zk-check-length
}

# TODO:
# - zk-fix-links. make sure A->B also has B->A link.
# - zk-fix-link-descriptions. Make sure A->B reflects the most recent title of B.
# - zk-review. cloze deletion? base it on #u and #r.
# - zk-import. import from readwise..?
# - zk-review-tag. fzf to select a tag.
# - zk-review-connect. try to connect with others.
# - zk-prune. take low U and consider deleting them.
