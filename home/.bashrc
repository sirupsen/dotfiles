#!/bin/bash

# Load colors
. ~/.colors

# Load functions
. ~/.bash_functions

# Vi command mode
set -o vi

# Default browser
BROWSER="chromium-dev" # Default browser

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
