. ~/.bashrc

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/simon/Downloads/google-cloud-sdk/path.bash.inc' ]; then . '/Users/simon/Downloads/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/simon/Downloads/google-cloud-sdk/completion.bash.inc' ]; then . '/Users/simon/Downloads/google-cloud-sdk/completion.bash.inc'; fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/simon/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/simon/miniforge3/etc/profile.d/conda.sh" ]; then
        . "/Users/simon/miniforge3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/simon/miniforge3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="/opt/homebrew/opt/mysql@5.7/bin:$PATH"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"

export PATH="$HOME/.poetry/bin:$PATH"
#source "/Users/simon/src/github.com/emscripten-core/emsdk/emsdk_env.sh"
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
