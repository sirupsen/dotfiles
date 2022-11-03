. ~/.bashrc

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/simon/Downloads/google-cloud-sdk/path.bash.inc' ]; then . '/Users/simon/Downloads/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/simon/Downloads/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/simon/Downloads/google-cloud-sdk/completion.bash.inc'; fi
export PATH="/opt/homebrew/opt/mysql@5.7/bin:$PATH"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"

# export PATH="$HOME/.poetry/bin:$PATH"
#source "/Users/simon/src/github.com/emscripten-core/emsdk/emsdk_env.sh"
# export GOENV_ROOT="$HOME/.goenv"
# export PATH="$GOENV_ROOT/bin:$PATH"
# if command -v goenv > /dev/null; then
#   eval "$(goenv init -)"
# fi

. /opt/homebrew/opt/asdf/libexec/asdf.sh
. /opt/homebrew/opt/asdf/etc/bash_completion.d/asdf.bash
