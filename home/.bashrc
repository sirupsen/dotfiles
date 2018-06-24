#!/bin/bash 
source /opt/dev/dev.sh

for file in ~/.bash/*.bash; do
  source $file
done

unset DISPLAY

eval "$(fasd --init auto)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export FZF_DEFAULT_OPTS="--height=40% --multi"
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/src
export PYTHONPATH=/usr/local/lib/python3.6/site-packages

export PATH=$GOPATH/bin:$PATH
export PATH="$HOME/.yarn/bin:$PATH"
export BACKTRACE=1
export GOPATH=$HOME
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.64.3:2376"
export DOCKER_CERT_PATH="/Users/sirup/.minikube/certs"
export DOCKER_API_VERSION="1.23"

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'
