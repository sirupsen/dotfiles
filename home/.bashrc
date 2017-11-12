#!/bin/bash 
source /opt/dev/dev.sh

for file in ~/.bash/*.bash; do
  source $file
done

unset DISPLAY

eval "$(fasd --init auto)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
export PATH=$GOPATH/bin:$PATH
export PATH="$HOME/.yarn/bin:$PATH"
export BACKTRACE=1
export GOPATH=$HOME
export DISABLE_DATABASE_ENVIRONMENT_CHECK=1
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.64.3:2376"
export DOCKER_CERT_PATH="/Users/sirup/.minikube/certs"
export DOCKER_API_VERSION="1.23"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sirup/src/google-cloud-sdk/path.bash.inc' ]; then source '/Users/sirup/src/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sirup/src/google-cloud-sdk/completion.bash.inc' ]; then source '/Users/sirup/src/google-cloud-sdk/completion.bash.inc'; fi
