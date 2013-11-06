#!/bin/bash

# Start from scratch

# OS X Homebrew
source /usr/local/etc/bash_completion.d/git-prompt.sh 2> /dev/null
# Ubuntu Linux
source /etc/bash_completion.d/git 2> /dev/null

# Set hostname if not on MacBook (home) and not in tmux (where hostname is shown
# right in the prompt).
if [[ ! $(hostname) =~ MacBook && -z $TMUX ]]; then
  PS1="\[$ORANGE\]\h \[$RED\]\W \[$YELLOW\]$(__git_ps1 " (%s)")\[${NORMAL}\]$ "
else
  PS1="\[$RED\]\W \[$YELLOW\]$(__git_ps1 " (%s)")\[${NORMAL}\]$ "
fi
