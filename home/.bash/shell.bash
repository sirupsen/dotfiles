# Notify immediatly on bg job completion
set -o notify

# Case insensitive autocompletion
shopt -s nocaseglob

# Vim as default editorj
export EDITOR=/usr/local/bin/nvim

export TERM=screen-256color
export PROMPT_COMMAND="history -a; history -r; ${PROMPT_COMMAND}"

# Plenty big history for searching backwards and doing analysis
export HISTFILESIZE=100000
export GPG_TTY=$(tty)
