#!/bin/bash

# Load colors
. ~/.colors

# Load functions
. ~/.bash_functions

# Vi command mode
set -o vi

# Default browser
BROWSER="chromium-browser" # Default browser

# Setting up editor 
EDITOR="vim" # Default editor
GIT_EDITOR=$EDITOR

# Add user bins to path
PATH=$PATH:~/.bin:/usr/local/bin

# Load Git completion
. ~/.git_completion

# Load PS1 theme
. ~/.bash_theme

# Source RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Load aliases at end to not conflict with anything
. ~/.bash_aliases

export PAGER="/bin/sh -c \"unset PAGER;col -b -x | \
  vim -R -c 'set ft=man nomod nolist' -c 'map q :q<CR>' \
  -c 'map <SPACE> <C-D>' -c 'map b <C-U>' \
  -c 'nmap K :Man <C-R>=expand(\\\"<cword>\\\")<CR><CR>' -\""
