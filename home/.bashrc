source /opt/dev/dev.sh

for file in ~/.bash/*.bash; do
  source "${file}"
done

source /etc/bashrc_Apple_Terminal

unset DISPLAY

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_OPTS="--height=40% --multi"
export FZF_DEFAULT_COMMAND='fd --no-ignore-vcs --exclude tmp --type f --follow --exclude .git --exclude rbi'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export BACKTRACE=1
export GOPATH=$HOME
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1

# export RUST_LOG=info
export RIPGREP_CONFIG_PATH="$HOME/.rgrc"

(ssh-add -l | grep -q "Error connecting to agent") && ssh-agent bash
(ssh-add -l | grep -q "no identities") && ssh-add -K

if [[ -f ~/.env ]]; then
  source ~/.env
fi

# cloudplatform: add Shopify clusters to your local kubernetes config
export KUBECONFIG=/Users/$(whoami)/.kube/config:/Users/$(whoami)/.kube/config.shopify.cloudplatform
for file in /Users/simoneskildsen/src/github.com/Shopify/cloudplatform/workflow-utils/*.bash; do source ${file}; done
kubectl-short-aliases
