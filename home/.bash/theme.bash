#!/bin/bash

# Start from scratch
PS1=''

# Set hostname if not on MacBook (home)
if [[ ! $(hostname) =~ MacBook ]]; then
  PS1="\[$ORANGE\]\h"
fi

# Put in current directory only
PS1+="\[$RED\]\W"

# If we have __git_ps1 installed, then put it in the prompt.
if [[ -r /usr/local/etc/bash_completion.d/git-prompt.sh ]]; then
  source /usr/local/etc/bash_completion.d/git-prompt.sh
  PS1+="\[$YELLOW\]$(__git_ps1 " (%s)")"
fi

# Normalize prompt contents
PS1+="\[${NORMAL}\] $ "
