set -o notify
shopt -s nocaseglob
export EDITOR=nvim
export TERM=screen-256color
# https://askubuntu.com/questions/67283/is-it-possible-to-make-writing-to-bash-history-immediate
shopt -s histappend # append, never overwrite
export PROMPT_COMMAND="history -a;history -r;$PROMPT_COMMAND"
export HISTFILESIZE=100000000
export GPG_TTY=$(tty)
