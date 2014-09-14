#!/bin/bash

# Notify immediatly on bg job completion
set -o notify

# Case insensitive autocompletion
shopt -s nocaseglob

# Vim as default editor
export EDITOR=/usr/bin/vim

# Prefer user-installed one
if [[ -x /usr/local/bin/vim ]]; then
  export EDITOR=/usr/local/bin/vim
fi

# To make Vim behave under xterm.
# Thanks, @teoljungberg
stty -ixon

export TERM=screen-256color

# Plenty big history for searching backwards and doing analysis
export HISTFILESIZE=100000
