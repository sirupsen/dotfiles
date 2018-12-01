set -o notify
shopt -s nocaseglob
export EDITOR=/usr/local/bin/nvim
export TERM=screen-256color
export PROMPT_COMMAND="history -a; history -r; ${PROMPT_COMMAND}"
export HISTFILESIZE=100000
export GPG_TTY=$(tty)
