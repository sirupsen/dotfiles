for file in ~/.bash/*.bash; do
  source "${file}"
done

source /etc/bashrc_Apple_Terminal

unset DISPLAY

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# I always have vim in left-most one... makes things easier. We could probably
# do something here to find the vim pid..?
export FZF_DEFAULT_OPTS="--height=40% --multi --tiebreak=begin \
  --bind 'ctrl-y:execute-silent(echo {} | pbcopy)' \
  --bind 'alt-down:preview-down,alt-up:preview-up' \
  --bind \"ctrl-v:execute-silent[ \
    tmux send-keys -t \{left\} Escape :vs Space && \
    tmux send-keys -t \{left\} -l {} && \
    tmux send-keys -t \{left\} Enter \
  ]\"
  --bind \"ctrl-x:execute-silent[ \
    tmux send-keys -t \{left\} Escape :sp Space && \
    tmux send-keys -t \{left\} -l {} && \
    tmux send-keys -t \{left\} Enter \
  ]\"
  --bind \"ctrl-o:execute-silent[ \
    tmux send-keys -t \{left\} Escape :read Space ! Space echo Space && \
    tmux send-keys -t \{left\} -l \\\"{}\\\" && \
    tmux send-keys -t \{left\} Enter \
  ]\""
# We depend on this in .vimrc too for file listing.
export FZF_DEFAULT_COMMAND="rg --files --follow --hidden --glob '!.git/*' --glob \
  '!sorbet/**' --glob '!tags' --glob '!yarn.lock' --glob '!package.json'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export GOPATH=$HOME

# export RUST_LOG=info
export RIPGREP_CONFIG_PATH="$HOME/.rgrc"

# Big node projects will be bogged down otherwise.
export NODE_OPTIONS='--max_old_space_size=4096'

(ssh-add -l | grep -q "Error connecting to agent") && ssh-agent bash
(ssh-add -l | grep -q "no identities") && ssh-add -K

if [[ -f ~/.env ]]; then
  source ~/.env
fi

if [[ $(whoami) == 'personal' ]]; then
  source /usr/local/share/chruby/chruby.sh
fi

# interactive
if [[ $- == *i* ]]; then
  if ! git --git-dir="$(z -e dotfiles)/.git" --work-tree="$(z -e dotfiles)" diff --quiet --exit-code; then
    echo -e "\x1b[33mDotfiles have uncomitted changes.\x1b[0m"
  fi
fi

# cloudplatform: add Shopify clusters to your local kubernetes config
export KUBECONFIG=/Users/$(whoami)/.kube/config:/Users/$(whoami)/.kube/config.shopify.cloudplatform
for file in /Users/work/src/github.com/Shopify/cloudplatform/workflow-utils/*.bash; do source ${file}; done
kubectl-short-aliases

export ZK_PATH="$HOME/Documents/Zettelkasten"
export PATH="$PATH:$HOME/src/zk/bin"

export CLASSPATH="build/core/lucene-core-8.5.1-SNAPSHOT.jar:build/analysis/common/lucene-analyzers-common-8.5.1-SNAPSHOT.jar:build/queryparser/lucene-queryparser-8.5.1-SNAPSHOT.jar:src/java"
export CLASSPATH="$CLASSPATH:build/demo/lucene-demo-8.5.1-SNAPSHOT.jar"

# load dev, but only if present and the shell is interactive
if [[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]]; then
  source /opt/dev/dev.sh
fi
