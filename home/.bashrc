source /opt/dev/dev.sh

for file in ~/.bash/*.bash; do
  source "${file}"
done

unset DISPLAY

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_OPTS="--height=40% --multi"
export FZF_DEFAULT_COMMAND='fd --type f --no-ignore'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export BACKTRACE=1
export GOPATH=$HOME
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1

# export RUST_LOG=info
export RIPGREP_CONFIG_PATH="$HOME/.rgrc"

(ssh-add -l | grep -q "no identities") && ssh-add -K

# cloudplatform: add Shopify clusters to your local kubernetes config
export KUBECONFIG=${KUBECONFIG:+$KUBECONFIG:}/Users/simon/.kube/config:/Users/simon/.kube/config.shopify.cloudplatform
for file in /Users/simon/src/github.com/Shopify/cloudplatform/workflow-utils/*.bash; do source ${file}; done
kubectl-short-aliases
