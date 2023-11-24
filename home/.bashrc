[ -f /etc/bashrc_Apple_Terminal ] && source /etc/bashrc_Apple_Terminal

for file in ~/.bash/*.bash; do
  source "${file}"
done

unset DISPLAY

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# I always have vim in left-most one... makes things easier. We could probably
# do something here to find the vim pid..?
export FZF_DEFAULT_OPTS="--height=40% --keep-right --multi --tiebreak=begin \
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
export FZF_DEFAULT_COMMAND="rg --files --follow --hidden --glob '!.git/*' \
  --glob '!tags' --glob '!*.rbi'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export GOPATH=$HOME/src
export GOROOT="$(asdf where golang)/go"

# export RUST_LOG=info
export RIPGREP_CONFIG_PATH="$HOME/.rgrc"

# Big node projects will be bogged down otherwise.
export NODE_OPTIONS='--max_old_space_size=4096'

# Interactive
if [[ $- == *i* ]]; then
  if [ $(uname) == "Darwin" ]; then
    (ssh-add -l 2>&1 | grep -q "Error connecting to agent") && ssh-agent bash
    (ssh-add -l 2>&1 | grep -q "no identities") && ssh-add --apple-use-keychain --apple-load-keychain
  else
    (ssh-add -l 2>&1 | grep -q "Error connecting to agent") && ssh-agent bash
    (ssh-add -l 2>&1 | grep -q "no identities") && ssh-add
  fi
fi

if [[ -f ~/.env ]]; then
  source ~/.env
fi

# interactive
if [[ $- == *i* ]]; then
  if ! git --git-dir="$(z -e dotfiles)/.git" --work-tree="$(z -e dotfiles)" diff --quiet --exit-code; then
    echo -e "\x1b[33mDotfiles have uncomitted changes.\x1b[0m"
  fi
fi

export KUBECONFIG=/Users/$(whoami)/.kube/config

if [ $(uname) == "Darwin" ]; then
  export ZK_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Documents/Zettelkasten"
else
  export ZK_PATH="$HOME/zettelkasten"
fi
export FTS_PATH=$ZK_PATH
export PATH="$PATH:$HOME/src/zk/bin"
export BIGTABLE_EMULATOR_HOST=localhost:8086

# load dev, but only if present and the shell is interactive
# if [[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]]; then
#   source /opt/dev/dev.sh
# fi

# if [ $(uname) == "Darwin" ]; then
#   source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
#   chruby 3
# else
#   source /usr/local/share/chruby/chruby.sh
# fi

# conda init "$(basename "${SHELL}")" > /dev/null 2>&1
# conda init bash
# source /Users/simon/src/github.com/vitessio/vitess/examples/local/env.sh

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export TSC_WATCHFILE=UseFsEventsWithFallbackDynamicPolling

# nvm use 16 > /dev/null
BUN_INSTALL="/Users/simon/.bun"
PATH="$BUN_INSTALL/bin:$PATH"
export OPENBLAS="$(brew --prefix openblas)"

# https://stackoverflow.com/questions/50168647/multiprocessing-causes-python-to-crash-and-gives-an-error-may-have-been-in-progr
# export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
source <(kubectl completion bash)
source ~/.kubectl_fzf.bash

PATH="/Users/simon/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/simon/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/simon/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/simon/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/simon/perl5"; export PERL_MM_OPT;
